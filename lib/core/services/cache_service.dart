import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported caching policies.
enum CachePolicy {
  /// Cache is stored in memory, lost when app is closed.
  memory,

  /// Cache is stored in SharedPreferences, survives app restarts.
  persistent,
}

/// A wrapper class representing a cached response.
class CacheEntry {
  final dynamic data;
  final DateTime expiry;

  CacheEntry({
    required this.data,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);

  Map<String, dynamic> toJson() => {
        'data': data,
        'expiry': expiry.toIso8601String(),
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
        data: json['data'],
        expiry: DateTime.parse(json['expiry'] as String),
      );
}

/// Abstract contract for a Cache Store.
abstract class CacheStore {
  Future<void> set(String key, CacheEntry entry);
  Future<CacheEntry?> get(String key);
  Future<void> delete(String key);
  Future<void> deleteMatching(String pathPattern);
  Future<void> clear();
}

/// In-memory cache implementation.
class MemoryCacheStore implements CacheStore {
  final Map<String, CacheEntry> _cache = {};

  @override
  Future<void> set(String key, CacheEntry entry) async {
    _cache[key] = entry;
  }

  @override
  Future<CacheEntry?> get(String key) async {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry;
  }

  @override
  Future<void> delete(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> deleteMatching(String pathPattern) async {
    _cache.removeWhere((key, _) => key.contains(pathPattern));
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }
}

/// Persistent cache implementation using SharedPreferences.
class SharedPreferencesCacheStore implements CacheStore {
  final SharedPreferences _prefs;
  static const String _keyPrefix = 'http_cache_';

  SharedPreferencesCacheStore(this._prefs);

  String _buildKey(String key) => '$_keyPrefix$key';

  @override
  Future<void> set(String key, CacheEntry entry) async {
    try {
      final jsonStr = json.encode(entry.toJson());
      await _prefs.setString(_buildKey(key), jsonStr);
    } catch (e) {
      debugPrint('Error serializing cache entry: $e');
    }
  }

  @override
  Future<CacheEntry?> get(String key) async {
    try {
      final jsonStr = _prefs.getString(_buildKey(key));
      if (jsonStr == null) return null;
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      final entry = CacheEntry.fromJson(map);
      if (entry.isExpired) {
        await delete(key);
        return null;
      }
      return entry;
    } catch (_) {
      await delete(key);
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(_buildKey(key));
  }

  @override
  Future<void> deleteMatching(String pathPattern) async {
    try {
      final keys = _prefs.getKeys().where((k) => k.startsWith(_keyPrefix) && k.contains(pathPattern)).toList();
      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error deleting matching cache keys: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      final keys = _prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing cache store: $e');
    }
  }
}

/// A class to configure Dio cache options helper.
class CacheOptions {
  /// Build options map to pass to `extra` field of Dio request Options.
  static Options build({
    bool cache = true,
    CachePolicy policy = CachePolicy.memory,
    Duration duration = const Duration(minutes: 5),
    bool refresh = false,
  }) {
    return Options(
      extra: {
        'cache': cache,
        'cache_policy': policy,
        'cache_duration': duration,
        'refresh': refresh,
      },
    );
  }
}

/// Dio Interceptor that handles HTTP request caching.
class CacheInterceptor extends Interceptor {
  final MemoryCacheStore _memoryStore;
  final SharedPreferencesCacheStore _persistentStore;

  CacheInterceptor({
    required MemoryCacheStore memoryStore,
    required SharedPreferencesCacheStore persistentStore,
  })  : _memoryStore = memoryStore,
        _persistentStore = persistentStore;

  String _generateCacheKey(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write(options.method.toUpperCase());
    buffer.write(':');
    buffer.write(options.path);
    if (options.queryParameters.isNotEmpty) {
      buffer.write('?');
      final sortedParams = Map.fromEntries(
        options.queryParameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      buffer.write(Uri(queryParameters: sortedParams.map((k, v) => MapEntry(k, v.toString()))).query);
    }
    return buffer.toString();
  }

  CacheStore _getStore(CachePolicy policy) {
    switch (policy) {
      case CachePolicy.persistent:
        return _persistentStore;
      case CachePolicy.memory:
      default:
        return _memoryStore;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final extra = options.extra;
    final isCacheEnabled = extra['cache'] == true;
    final isGetRequest = options.method.toUpperCase() == 'GET';

    if (!isCacheEnabled || !isGetRequest) {
      return handler.next(options);
    }

    final refresh = extra['refresh'] == true;
    final key = _generateCacheKey(options);
    final policy = extra['cache_policy'] as CachePolicy? ?? CachePolicy.memory;
    final store = _getStore(policy);

    if (refresh) {
      debugPrint('[CacheInterceptor] Forced refresh for: ${options.path}');
      return handler.next(options);
    }

    try {
      final cachedEntry = await store.get(key);
      if (cachedEntry != null) {
        debugPrint('[CacheInterceptor] Serving cached response for: ${options.path}');
        final response = Response(
          requestOptions: options,
          data: cachedEntry.data,
          statusCode: 200,
          statusMessage: 'OK (Cached)',
        );
        return handler.resolve(response);
      }
    } catch (e) {
      debugPrint('[CacheInterceptor] Failed to retrieve cached response: $e');
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final options = response.requestOptions;
    final extra = options.extra;
    final isCacheEnabled = extra['cache'] == true;
    final isGetRequest = options.method.toUpperCase() == 'GET';

    if (isCacheEnabled && isGetRequest && response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      final duration = extra['cache_duration'] as Duration? ?? const Duration(minutes: 5);
      final policy = extra['cache_policy'] as CachePolicy? ?? CachePolicy.memory;
      final store = _getStore(policy);
      final key = _generateCacheKey(options);
      final expiry = DateTime.now().add(duration);
      final entry = CacheEntry(data: response.data, expiry: expiry);

      try {
        await store.set(key, entry);
        debugPrint('[CacheInterceptor] Cached response for ${options.path} (Expiry: ${expiry.toLocal()})');
      } catch (e) {
        debugPrint('[CacheInterceptor] Failed to save cache entry: $e');
      }
    }

    return handler.next(response);
  }
}
