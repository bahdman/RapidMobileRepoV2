import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';
import 'package:rapid_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SharedPrefsHelper _prefsHelper;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  AuthBloc(this._authRepository, this._prefsHelper) : super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignIn);
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // 1. Authenticate with Google
      if (!_isInitialized) {
        await _googleSignIn.initialize();
        _isInitialized = true;
      }

      final GoogleSignInAccount googleUser;
      try {
        googleUser = await _googleSignIn.authenticate();
      } catch (e) {
        // User cancelled / aborted the Google sign-in sheet — not an API error
        emit(AuthError('Google Sign-In aborted: $e'));
        return;
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        emit(const AuthError('Failed to retrieve ID Token from Google.'));
        return;
      }

      // 2. Attempt Login
      try {
        final loginResponse = await _authRepository.googleLogin(idToken);
        if (loginResponse.data != null) {
          await _prefsHelper.saveToken(loginResponse.data!.accessToken);
          emit(AuthAuthenticated());
          return;
        } else {
          emit(const AuthError('Login failed: invalid response data.'));
          return;
        }
      } on DioException catch (e) {
        // If 401, proceed to Register flow
        if (e.response?.statusCode != 401) {
          emit(AuthError('Google Login Failed: ${e.message}', isApiError: true));
          return;
        }
      }

      // 3. Registration flow (since Login returned 401)
      final registerResponse = await _authRepository.googleRegister(idToken);
      if (registerResponse.data == null) {
        emit(const AuthError('Registration failed: no data returned.', isApiError: true));
        return;
      }

      final String newUserId = registerResponse.data!.id;

      // 4. Accept terms for the new user
      final termsResponse = await _authRepository.acceptGoogleTerms(newUserId, true);
      if (termsResponse.data != null && termsResponse.data!.authCredentials != null) {
        await _prefsHelper.saveToken(termsResponse.data!.authCredentials!.accessToken);
        emit(AuthAuthenticated());
      } else {
        emit(const AuthError('Failed to retrieve tokens after accepting terms.', isApiError: true));
      }
    } catch (e) {
      emit(AuthError(e.toString(), isApiError: true));
    }
  }
}
