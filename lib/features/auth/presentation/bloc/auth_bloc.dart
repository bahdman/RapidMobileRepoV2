import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rapid_app/core/services/push_notification_service.dart';
import 'package:rapid_app/core/services/user_service.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';
import 'package:rapid_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SharedPrefsHelper _prefsHelper;
  final UserService _userService;
  final PushNotificationService _pushNotificationService;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  AuthBloc(
    this._authRepository,
    this._prefsHelper,
    this._userService,
    this._pushNotificationService,
  ) : super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<TermsAccepted>(_onTermsAccepted);
    on<CreateEmailAccountRequested>(_onCreateEmailAccount);
    on<CompleteOnboardingRequested>(_onCompleteOnboarding);
    on<RequestOtpRequested>(_onRequestOtp);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<AppAuthLoginRequested>(_onAppAuthLogin);
    on<GenerateAccessTokenRequested>(_onGenerateAccessToken);
    on<LogoutRequested>(_onLogout);
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

      debugPrint('================ GOOGLE ID TOKEN ================');
      debugPrint(idToken);
      debugPrint('================================================');

      // Copy to clipboard because debug console might truncate long strings
      await Clipboard.setData(ClipboardData(text: idToken));

      // 2. Attempt Login
      try {
        final loginResponse = await _authRepository.googleLogin(idToken);
        if (loginResponse.data != null) {
          final data = loginResponse.data!;
          await _prefsHelper.saveToken(data.accessToken);
          await _prefsHelper.saveRefreshToken(data.refreshToken);
          await _prefsHelper.saveAccessTokenExpiry(data.accessTokenExpiry);
          await _prefsHelper.saveRefreshTokenExpiry(data.refreshTokenExpiry);
          // Save userId for logout and other purposes
          await _prefsHelper.saveUser(data.id);

          // Populate user profile with Google email and name
          final email = _getEmailFromJwt(data.accessToken) ?? googleUser.email;
          final name = data.name;
          final nameParts = name.trim().split(RegExp(r'\s+'));
          final firstName = nameParts.isNotEmpty ? nameParts.first : '';
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          try {
            await _userService.updateUserProfile(
              email: email,
              firstName: firstName,
              lastName: lastName,
              phoneNumber: '',
            );
          } catch (profileError) {
            debugPrint('Failed to update user profile on Google login: $profileError');
          }

          emit(AuthAuthenticated());
          // Register device token with the backend after successful login
          unawaited(_pushNotificationService.registerDevice());
          return;
        } else {
          emit(const AuthError('Login failed: invalid response data.'));
          return;
        }
      } on DioException catch (e, stackTrace) {
        // If 401, proceed to Register flow
        if (e.response?.statusCode != 401) {
          _handleError(e, stackTrace, emit);
          return;
        }
      }

      // 3. Registration flow (since Login returned 401)
      final registerResponse = await _authRepository.googleRegister(idToken);
      if (registerResponse.data == null) {
        emit(const AuthError('Registration failed: no data returned.', isApiError: true));
        return;
      }

      // Stop here and let the user accept terms manually on the next screen
      emit(AuthRegisterSuccess(registerResponse.data!));
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _onTermsAccepted(
    TermsAccepted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final termsResponse = await _authRepository.acceptGoogleTerms(event.userId, event.acceptTerms);
      if (termsResponse.data != null && termsResponse.data!.authCredentials != null) {
        final data = termsResponse.data!;
        final credentials = data.authCredentials!;
        await _prefsHelper.saveToken(credentials.accessToken);
        await _prefsHelper.saveRefreshToken(credentials.refreshToken);
        await _prefsHelper.saveAccessTokenExpiry(credentials.accessTokenExpiry);
        await _prefsHelper.saveRefreshTokenExpiry(credentials.refreshTokenExpiry);

        // Populate user profile with Google email and name
        final email = _getEmailFromJwt(credentials.accessToken) ?? '';
        final firstName = data.firstName;
        final lastName = data.lastName;
        try {
          await _userService.updateUserProfile(
            email: email,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: '',
          );
        } catch (profileError) {
          debugPrint('Failed to update user profile on terms accepted: $profileError');
        }

        emit(AuthAuthenticated());
        // Register device token with the backend after accepting terms
        unawaited(_pushNotificationService.registerDevice());
      } else {
        emit(const AuthError('Failed to retrieve tokens after accepting terms.', isApiError: true));
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _onCreateEmailAccount(
    CreateEmailAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.createEmailAccount(event.request);
      if (response.data != null) {
        emit(CreateEmailAccountSuccess(response.data!));
      } else {
        emit(const AuthError('Failed to create account: no data returned.', isApiError: true));
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.completeOnboarding(event.request);
      if (response.data != null && response.data!.authCredentials != null) {
        await _prefsHelper.saveToken(response.data!.authCredentials!.accessToken);
        await _prefsHelper.saveRefreshToken(response.data!.authCredentials!.refreshToken);
        await _prefsHelper.saveAccessTokenExpiry(response.data!.authCredentials!.accessTokenExpiry);
        await _prefsHelper.saveRefreshTokenExpiry(response.data!.authCredentials!.refreshTokenExpiry);
        emit(AuthAuthenticated());
        // Register device token for email onboarding completion
        unawaited(_pushNotificationService.registerDevice());
      } else {
        emit(const AuthError('Failed to retrieve tokens after onboarding.', isApiError: true));
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _onRequestOtp(
    RequestOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.requestOtp(event.request);
      if (response.data != null) {
        emit(RequestOtpSuccess(response.data!));
      } else {
        emit(const AuthError('Failed to request OTP: no data returned.', isApiError: true));
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.verifyOtp(event.request);
      if (response.data != null) {
        final data = response.data!;
        if (data.isFirstLogin) {
          // Navigate to create account flow
          emit(AuthNeedsOnboarding(data.onboardingToken ?? ''));
        } else {
          // Navigate to home page
          if (data.authCredentials != null) {
            await _prefsHelper.saveToken(data.authCredentials!.accessToken);
            await _prefsHelper.saveRefreshToken(data.authCredentials!.refreshToken);
            await _prefsHelper.saveAccessTokenExpiry(data.authCredentials!.accessTokenExpiry);
            await _prefsHelper.saveRefreshTokenExpiry(data.authCredentials!.refreshTokenExpiry);
            // In a real scenario, VerifyOtpResponse might need to include userId
            // if it's not already in authCredentials or known.
            // For now, if onboardingToken is null and we have credentials, we assume login.
            emit(AuthAuthenticated());
            // Register device token after OTP verification
            unawaited(_pushNotificationService.registerDevice());
          } else {
            emit(const AuthError('Missing auth credentials for login.', isApiError: true));
          }
        }
      } else {
        emit(const AuthError('Failed to verify OTP: no data returned.', isApiError: true));
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _onAppAuthLogin(
    AppAuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.appAuthLogin(event.request);
      if (response.data != null) {
        await _prefsHelper.saveToken(response.data!.accessToken);
        await _prefsHelper.saveRefreshToken(response.data!.refreshToken);
        await _prefsHelper.saveAccessTokenExpiry(response.data!.accessTokenExpiry);
        await _prefsHelper.saveRefreshTokenExpiry(response.data!.refreshTokenExpiry);
        await _prefsHelper.saveUser(response.data!.userId);
        emit(AppAuthLoginSuccess(response.data!));
        emit(AuthAuthenticated());
        // Register device token after app-auth login
        unawaited(_pushNotificationService.registerDevice());
      } else {
        emit(const AuthError('Login failed: no data returned.', isApiError: true));
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _onGenerateAccessToken(
    GenerateAccessTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.generateAccessToken(event.request);
      if (response.data != null) {
        await _prefsHelper.saveToken(response.data!.accessToken);
        await _prefsHelper.saveRefreshToken(response.data!.refreshToken);
        await _prefsHelper.saveAccessTokenExpiry(response.data!.accessTokenExpiresAtUtc);
        await _prefsHelper.saveRefreshTokenExpiry(response.data!.refreshTokenExpiresAtUtc);
        // We might not need to emit anything for a background refresh
        // But for completeness we can emit authenticated
        emit(AuthAuthenticated());
        // Re-register push token in case it was refreshed
        unawaited(_pushNotificationService.registerDevice());
      } else {
        emit(const AuthError('Failed to refresh token: no data returned.', isApiError: true));
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final refreshToken = _prefsHelper.getRefreshToken() ?? '';
      await _authRepository.logout(LogoutRequest(userId: event.userId, refreshToken: refreshToken));
      // Deactivate push token and clear all caches before wiping credentials
      await _pushNotificationService.deactivateDevice();
      await _userService.clearCache();
      await _prefsHelper.clearAuth();
      emit(AuthLoggedOut());
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  String? _getEmailFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decodedString = utf8.decode(base64Url.decode(normalized));
      final decodedMap = json.decode(decodedString) as Map<String, dynamic>;
      return decodedMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] as String?;
    } catch (e) {
      debugPrint('Error parsing email from JWT: $e');
      return null;
    }
  }

  void _handleError(dynamic error, StackTrace stackTrace, Emitter<AuthState> emit) {
    String userMessage = 'An unexpected error occurred';
    bool isApiError = false;

    if (error is DioException) {
      isApiError = true;
      final statusCode = error.response?.statusCode;
      String? apiMessage;
      if (error.response?.data != null && error.response!.data is Map<String, dynamic>) {
        final map = error.response!.data as Map<String, dynamic>;
        if (map.containsKey('message') && map['message'] != null) {
          apiMessage = map['message'].toString();
        }
      }
      userMessage = apiMessage ?? error.message ?? 'Error [${statusCode ?? 'Unknown'}]';
      
      debugPrint('================ DEVELOPER LOG ================');
      debugPrint('Source: AuthBloc API Call');
      debugPrint('Type: DioException');
      debugPrint('Status Code: $statusCode');
      debugPrint('Path: ${error.requestOptions.path}');
      debugPrint('Error: ${error.message}');
      if (error.response?.data != null) {
        debugPrint('Response Body: ${error.response?.data}');
      }
      debugPrint('Stacktrace: $stackTrace');
      debugPrint('==============================================');
    } else {
      debugPrint('================ DEVELOPER LOG ================');
      debugPrint('Source: AuthBloc Internal');
      debugPrint('Error: $error');
      debugPrint('Stacktrace: $stackTrace');
      debugPrint('==============================================');
    }

    emit(AuthError(userMessage, isApiError: isApiError));
  }
}
