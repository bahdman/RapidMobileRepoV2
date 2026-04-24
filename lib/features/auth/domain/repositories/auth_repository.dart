import 'package:rapid_app/core/models/api_response.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';

abstract class AuthRepository {
  Future<ApiResponse<GoogleAuthUser>> googleRegister(String token);
  Future<ApiResponse<GoogleTermsData>> acceptGoogleTerms(String userId, bool acceptTerms);
  Future<ApiResponse<GoogleLoginData>> googleLogin(String token);
  Future<ApiResponse<CreateEmailAccountResponse>> createEmailAccount(CreateEmailAccountRequest request);
  Future<ApiResponse<CompleteOnboardingResponse>> completeOnboarding(CompleteOnboardingRequest request);
  Future<ApiResponse<RequestOtpResponse>> requestOtp(RequestOtpRequest request);
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(VerifyOtpRequest request);
  Future<ApiResponse<AppAuthLoginResponse>> appAuthLogin(AppAuthLoginRequest request);
  Future<ApiResponse<GenerateAccessTokenResponse>> generateAccessToken(GenerateAccessTokenRequest request);
}
