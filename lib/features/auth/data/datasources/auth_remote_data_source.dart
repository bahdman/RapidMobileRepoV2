import 'package:dio/dio.dart';
import 'package:rapid_app/core/config/api_config.dart';
import 'package:rapid_app/core/models/api_response.dart';
import 'package:rapid_app/core/services/api_service.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResponse<GoogleAuthUser>> googleRegister(String token);
  Future<ApiResponse<GoogleTermsData>> acceptGoogleTerms(String userId, bool acceptTerms);
  Future<ApiResponse<GoogleLoginData>> googleLogin(String token);
  Future<ApiResponse<CreateEmailAccountResponse>> createEmailAccount(CreateEmailAccountRequest request);
  Future<ApiResponse<CompleteOnboardingResponse>> completeOnboarding(CompleteOnboardingRequest request);
  Future<ApiResponse<RequestOtpResponse>> requestOtp(RequestOtpRequest request);
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(VerifyOtpRequest request);
  Future<ApiResponse<AppAuthLoginResponse>> appAuthLogin(AppAuthLoginRequest request);
  Future<ApiResponse<GenerateAccessTokenResponse>> generateAccessToken(GenerateAccessTokenRequest request);
  Future<ApiResponse<bool>> logout(LogoutRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<ApiResponse<GoogleAuthUser>> googleRegister(String token) async {
    final response = await _apiService.post(
      ApiConfig.googleRegister,
      data: {'token': token},
    );
    return ApiResponse<GoogleAuthUser>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => GoogleAuthUser.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<GoogleTermsData>> acceptGoogleTerms(String userId, bool acceptTerms) async {
    final response = await _apiService.post(
      ApiConfig.googleAcceptTerms,
      data: {
        'userId': userId,
        'acceptTerms': acceptTerms,
      },
    );
    return ApiResponse<GoogleTermsData>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => GoogleTermsData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<GoogleLoginData>> googleLogin(String token) async {
    final response = await _apiService.post(
      ApiConfig.googleLogin,
      data: {'token': token},
    );
    return ApiResponse<GoogleLoginData>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => GoogleLoginData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<CreateEmailAccountResponse>> createEmailAccount(CreateEmailAccountRequest request) async {
    final response = await _apiService.post(
      ApiConfig.createEmailAccount,
      data: request.toJson(),
    );
    return ApiResponse<CreateEmailAccountResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => CreateEmailAccountResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<CompleteOnboardingResponse>> completeOnboarding(CompleteOnboardingRequest request) async {
    final response = await _apiService.post(
      ApiConfig.completeOnboarding,
      data: request.toJson(),
    );
    return ApiResponse<CompleteOnboardingResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => CompleteOnboardingResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<RequestOtpResponse>> requestOtp(RequestOtpRequest request) async {
    final response = await _apiService.post(
      ApiConfig.requestOtp,
      data: request.toJson(),
    );
    return ApiResponse<RequestOtpResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => RequestOtpResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(VerifyOtpRequest request) async {
    final response = await _apiService.post(
      ApiConfig.verifyOtp,
      data: request.toJson(),
    );
    return ApiResponse<VerifyOtpResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => VerifyOtpResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<AppAuthLoginResponse>> appAuthLogin(AppAuthLoginRequest request) async {
    final response = await _apiService.post(
      ApiConfig.appAuthLogin,
      data: request.toJson(),
    );
    return ApiResponse<AppAuthLoginResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => AppAuthLoginResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<GenerateAccessTokenResponse>> generateAccessToken(GenerateAccessTokenRequest request) async {
    final response = await _apiService.post(
      ApiConfig.generateAccessToken,
      data: request.toJson(),
    );
    return ApiResponse<GenerateAccessTokenResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => GenerateAccessTokenResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<bool>> logout(LogoutRequest request) async {
    final response = await _apiService.post(
      ApiConfig.appAuthLogout,
      data: request.toJson(),
    );
    return ApiResponse<bool>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => json as bool,
    );
  }
}
