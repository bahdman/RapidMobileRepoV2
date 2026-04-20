import 'package:rapid_app/core/models/api_response.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';

abstract class AuthRepository {
  Future<ApiResponse<GoogleAuthUser>> googleRegister(String token);
  Future<ApiResponse<GoogleTermsData>> acceptGoogleTerms(String userId, bool acceptTerms);
  Future<ApiResponse<GoogleLoginData>> googleLogin(String token);
}
