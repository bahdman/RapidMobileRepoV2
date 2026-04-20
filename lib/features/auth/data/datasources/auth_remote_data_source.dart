import 'package:dio/dio.dart';
import 'package:rapid_app/core/config/api_config.dart';
import 'package:rapid_app/core/models/api_response.dart';
import 'package:rapid_app/core/services/api_service.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResponse<GoogleAuthUser>> googleRegister(String token);
  Future<ApiResponse<GoogleTermsData>> acceptGoogleTerms(String userId, bool acceptTerms);
  Future<ApiResponse<GoogleLoginData>> googleLogin(String token);
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
}
