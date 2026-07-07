import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/shared_prefs_helper.dart';
import 'token_refresh_interceptor.dart';
import 'cache_service.dart';

class ApiService {
  final Dio _dio;
  final SharedPrefsHelper _prefs;
  late final MemoryCacheStore memoryCacheStore;
  late final SharedPreferencesCacheStore persistentCacheStore;

  ApiService(this._prefs, SharedPreferences sharedPreferences)
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    memoryCacheStore = MemoryCacheStore();
    persistentCacheStore = SharedPreferencesCacheStore(sharedPreferences);

    _dio.interceptors.addAll([
      // 1. Attach the stored access token to every outgoing request.
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _prefs.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (e, handler) {
          return handler.next(e);
        },
      ),
      // 2. Intercept 401s, refresh the token, and retry the original request.
      TokenRefreshInterceptor(_dio, _prefs),
      // 3. HTTP Request Caching Interceptor.
      CacheInterceptor(
        memoryStore: memoryCacheStore,
        persistentStore: persistentCacheStore,
      ),
      // 4. Log all traffic (after refresh so retried requests are also logged).
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (Object object) {
          debugPrint(object.toString());
        },
      ),
    ]);
  }

  /// Invalidates (clears) cached entries whose keys match or contain the given [pathPattern].
  Future<void> invalidateCache(String pathPattern) async {
    debugPrint('[ApiService] Invalidating cache for pattern: $pathPattern');
    await memoryCacheStore.deleteMatching(pathPattern);
    await persistentCacheStore.deleteMatching(pathPattern);
  }

  /// Clears all cached HTTP requests.
  Future<void> clearAllCache() async {
    debugPrint('[ApiService] Clearing all request caches');
    await memoryCacheStore.clear();
    await persistentCacheStore.clear();
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.post(path, data: data, options: options);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.put(path, data: data, options: options);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.delete(path, data: data, options: options);
  }
}
