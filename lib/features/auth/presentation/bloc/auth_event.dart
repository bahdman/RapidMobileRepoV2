import 'package:equatable/equatable.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class GoogleSignInRequested extends AuthEvent {}

class TermsAccepted extends AuthEvent {
  final String userId;
  final bool acceptTerms;

  const TermsAccepted({required this.userId, required this.acceptTerms});

  @override
  List<Object?> get props => [userId, acceptTerms];
}

class CreateEmailAccountRequested extends AuthEvent {
  final CreateEmailAccountRequest request;

  const CreateEmailAccountRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class CompleteOnboardingRequested extends AuthEvent {
  final CompleteOnboardingRequest request;

  const CompleteOnboardingRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class RequestOtpRequested extends AuthEvent {
  final RequestOtpRequest request;

  const RequestOtpRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class VerifyOtpRequested extends AuthEvent {
  final VerifyOtpRequest request;

  const VerifyOtpRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class AppAuthLoginRequested extends AuthEvent {
  final AppAuthLoginRequest request;

  const AppAuthLoginRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class GenerateAccessTokenRequested extends AuthEvent {
  final GenerateAccessTokenRequest request;

  const GenerateAccessTokenRequested(this.request);

  @override
  List<Object?> get props => [request];
}
