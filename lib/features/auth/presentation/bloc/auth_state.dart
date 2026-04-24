import 'package:equatable/equatable.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';

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

class AuthRegisterSuccess extends AuthState {
  final GoogleAuthUser user;
  const AuthRegisterSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthTermsAccepted extends AuthState {}

class CreateEmailAccountSuccess extends AuthState {
  final CreateEmailAccountResponse response;

  const CreateEmailAccountSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class RequestOtpSuccess extends AuthState {
  final RequestOtpResponse response;

  const RequestOtpSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthNeedsOnboarding extends AuthState {
  final String onboardingToken;

  const AuthNeedsOnboarding(this.onboardingToken);

  @override
  List<Object?> get props => [onboardingToken];
}

class AppAuthLoginSuccess extends AuthState {
  final AppAuthLoginResponse response;

  const AppAuthLoginSuccess(this.response);

  @override
  List<Object?> get props => [response];
}
