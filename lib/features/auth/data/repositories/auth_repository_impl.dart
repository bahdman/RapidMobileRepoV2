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
}
