import 'package:rapid_app/core/models/api_response.dart';
import 'package:rapid_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';
import 'package:rapid_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResponse<GoogleAuthUser>> googleRegister(String token) async {
    try {
      return await _remoteDataSource.googleRegister(token);
    } catch (e) {
      // Dio exceptions are typically handled by an interceptor or higher up,
      // but we can rethrow or map them here if needed.
      rethrow;
    }
  }

  @override
  Future<ApiResponse<GoogleTermsData>> acceptGoogleTerms(String userId, bool acceptTerms) async {
    try {
      return await _remoteDataSource.acceptGoogleTerms(userId, acceptTerms);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<GoogleLoginData>> googleLogin(String token) async {
    try {
      return await _remoteDataSource.googleLogin(token);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<CreateEmailAccountResponse>> createEmailAccount(CreateEmailAccountRequest request) async {
    try {
      return await _remoteDataSource.createEmailAccount(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<CompleteOnboardingResponse>> completeOnboarding(CompleteOnboardingRequest request) async {
    try {
      return await _remoteDataSource.completeOnboarding(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<RequestOtpResponse>> requestOtp(RequestOtpRequest request) async {
    try {
      return await _remoteDataSource.requestOtp(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(VerifyOtpRequest request) async {
    try {
      return await _remoteDataSource.verifyOtp(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<AppAuthLoginResponse>> appAuthLogin(AppAuthLoginRequest request) async {
    try {
      return await _remoteDataSource.appAuthLogin(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<GenerateAccessTokenResponse>> generateAccessToken(GenerateAccessTokenRequest request) async {
    try {
      return await _remoteDataSource.generateAccessToken(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<bool>> logout(LogoutRequest request) async {
    try {
      return await _remoteDataSource.logout(request);
    } catch (e) {
      rethrow;
    }
  }
}
