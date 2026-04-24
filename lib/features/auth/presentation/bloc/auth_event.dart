import 'package:equatable/equatable.dart';

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
