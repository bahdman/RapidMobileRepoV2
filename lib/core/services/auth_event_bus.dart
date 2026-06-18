import 'dart:async';

/// A singleton event bus used to broadcast authentication-level events
/// (e.g. session expiry) from services/interceptors to the UI layer
/// without coupling them through BuildContext or router.
class AuthEventBus {
  AuthEventBus._();
  static final AuthEventBus instance = AuthEventBus._();

  final _controller = StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get stream => _controller.stream;

  void publish(AuthEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}

enum AuthEvent {
  /// Fired when a 401 is received and the token refresh also fails,
  /// meaning the user's session is completely invalid.
  sessionExpired,
}
