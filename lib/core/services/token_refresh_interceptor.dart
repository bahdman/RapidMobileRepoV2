import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rapid_app/core/config/api_config.dart';
import 'package:rapid_app/core/services/auth_event_bus.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';

/// A Dio interceptor that automatically refreshes the access token when a
/// 401 Unauthorized response is received, then retries the original request.
///
/// Uses a simple boolean lock ([_isRefreshing]) to prevent concurrent refresh
/// requests when multiple API calls fail simultaneously. Additional requests
/// that arrive while a refresh is in flight are queued and resolved together.
class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  final SharedPrefsHelper _prefs;

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingQueue = [];

  TokenRefreshInterceptor(this._dio, this._prefs);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;

    // Only intercept 401 errors — and skip the token refresh endpoint itself
    // to avoid infinite refresh loops.
    if (response?.statusCode != 401 ||
        (err.requestOptions.path.contains(ApiConfig.generateAccessToken))) {
      return handler.next(err);
    }

    final userId = _prefs.getUser();
    final refreshToken = _prefs.getRefreshToken();

    if (userId == null || refreshToken == null || refreshToken.isEmpty) {
      // No credentials to refresh with — clear auth and signal the UI.
      debugPrint('[TokenRefresh] No credentials available. Forcing logout.');
      await _prefs.clearAuth();
      AuthEventBus.instance.publish(AuthEvent.sessionExpired);
      return handler.next(err);
    }

    if (_isRefreshing) {
      // A refresh is already in flight. Queue this request to retry once done.
      debugPrint('[TokenRefresh] Refresh in flight — queuing request.');
      final completer = _PendingRequest(err.requestOptions, handler);
      _pendingQueue.add(completer);
      return;
    }

    _isRefreshing = true;
    debugPrint('[TokenRefresh] Access token expired — refreshing...');

    try {
      // Call the refresh endpoint using a raw Dio instance (no interceptors)
      // so we don't recurse back into this interceptor.
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      final refreshResponse = await refreshDio.post(
        ApiConfig.generateAccessToken,
        data: {
          'userId': userId,
          'refreshToken': refreshToken,
        },
      );

      // Parse the envelope: { isSuccess, statusCode, message, data: { ... } }
      final envelope = refreshResponse.data;
      if (envelope is! Map<String, dynamic>) {
        throw Exception('Unexpected token refresh response format');
      }

      final isSuccess = envelope['isSuccess'] as bool? ?? false;
      if (!isSuccess) {
        final message = envelope['message'] as String? ?? 'Token refresh failed';
        throw Exception(message);
      }

      final tokenData = envelope['data'] as Map<String, dynamic>?;
      if (tokenData == null) {
        throw Exception('Missing data in token refresh response');
      }

      final newAccessToken = tokenData['accessToken'] as String? ?? '';
      final newRefreshToken = tokenData['refreshToken'] as String? ?? '';
      final newAccessExpiry = tokenData['accessTokenExpiresAtUtc'] as String? ?? '';
      final newRefreshExpiry = tokenData['refreshTokenExpiresAtUtc'] as String? ?? '';

      if (newAccessToken.isEmpty) {
        throw Exception('Empty access token in refresh response');
      }

      // Persist the new tokens and their expiry times.
      await _prefs.saveToken(newAccessToken);
      if (newRefreshToken.isNotEmpty) await _prefs.saveRefreshToken(newRefreshToken);
      if (newAccessExpiry.isNotEmpty) await _prefs.saveAccessTokenExpiry(newAccessExpiry);
      if (newRefreshExpiry.isNotEmpty) await _prefs.saveRefreshTokenExpiry(newRefreshExpiry);

      debugPrint('[TokenRefresh] Tokens refreshed. Access expires: $newAccessExpiry');

      // Retry the original failed request with the new token.
      final retryResponse = await _retry(err.requestOptions, newAccessToken);
      handler.resolve(retryResponse);

      // Resolve all queued requests.
      for (final pending in _pendingQueue) {
        try {
          final res = await _retry(pending.options, newAccessToken);
          pending.handler.resolve(res);
        } catch (e) {
          pending.handler.next(
            DioException(requestOptions: pending.options, error: e),
          );
        }
      }
    } catch (e) {
      debugPrint('[TokenRefresh] Token refresh failed — forcing logout: $e');
      // Refresh failed: clear stored credentials and notify the UI to re-authenticate.
      await _prefs.clearAuth();
      AuthEventBus.instance.publish(AuthEvent.sessionExpired);
      handler.next(err);
      for (final pending in _pendingQueue) {
        pending.handler.next(
          DioException(requestOptions: pending.options, error: e),
        );
      }
    } finally {
      _isRefreshing = false;
      _pendingQueue.clear();
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String newToken,
  ) {
    final opts = options.copyWith(
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $newToken',
      },
    );
    return _dio.fetch(opts);
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}
