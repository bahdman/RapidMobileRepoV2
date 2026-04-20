import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  /// True when the error originates from an API call (show snackbar).
  /// False for 3rd-party SDK errors like a cancelled Google Sign-In.
  final bool isApiError;

  const AuthError(this.message, {this.isApiError = false});

  @override
  List<Object?> get props => [message, isApiError];
}
