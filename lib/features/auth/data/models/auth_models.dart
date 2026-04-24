class GoogleAuthUser {
  final String id;
  final String firstName;
  final String lastName;

  GoogleAuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory GoogleAuthUser.fromJson(Map<String, dynamic> json) {
    return GoogleAuthUser(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
    );
  }
}

class AuthCredentials {
  final String accessToken;
  final String refreshToken;

  AuthCredentials({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthCredentials.fromJson(Map<String, dynamic> json) {
    return AuthCredentials(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}

class GoogleTermsData {
  final String id;
  final String firstName;
  final String lastName;
  final String? dateAccepted;
  final AuthCredentials? authCredentials;

  GoogleTermsData({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.dateAccepted,
    this.authCredentials,
  });

  factory GoogleTermsData.fromJson(Map<String, dynamic> json) {
    return GoogleTermsData(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateAccepted: json['dateAccepted'] as String?,
      authCredentials: json['authCredentials'] != null
          ? AuthCredentials.fromJson(json['authCredentials'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GoogleLoginData {
  final String id;
  final String name;
  final String accessToken;
  final String refreshToken;

  GoogleLoginData({
    required this.id,
    required this.name,
    required this.accessToken,
    required this.refreshToken,
  });

  factory GoogleLoginData.fromJson(Map<String, dynamic> json) {
    return GoogleLoginData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}

class CreateEmailAccountRequest {
  final String email;
  final String password;
  final String confirmPassword;

  CreateEmailAccountRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}

class CreateEmailAccountResponse {
  final String userId;
  final String email;
  final bool isFirstLogin;
  final bool termsAccepted;

  CreateEmailAccountResponse({
    required this.userId,
    required this.email,
    required this.isFirstLogin,
    required this.termsAccepted,
  });

  factory CreateEmailAccountResponse.fromJson(Map<String, dynamic> json) {
    return CreateEmailAccountResponse(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isFirstLogin: json['isFirstLogin'] as bool? ?? false,
      termsAccepted: json['termsAccepted'] as bool? ?? false,
    );
  }
}

class CompleteOnboardingRequest {
  final String onboardingToken;
  final String firstName;
  final String lastName;
  final String dob;
  final bool acceptTerms;
  final String password;
  final String confirmPassword;

  CompleteOnboardingRequest({
    required this.onboardingToken,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.acceptTerms,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'onboardingToken': onboardingToken,
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'acceptTerms': acceptTerms,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}

class CompleteOnboardingResponse {
  final String id;
  final String firstName;
  final String lastName;
  final AuthCredentials? authCredentials;

  CompleteOnboardingResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.authCredentials,
  });

  factory CompleteOnboardingResponse.fromJson(Map<String, dynamic> json) {
    return CompleteOnboardingResponse(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      authCredentials: json['authCredentials'] != null
          ? AuthCredentials.fromJson(json['authCredentials'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RequestOtpRequest {
  final String contact;

  RequestOtpRequest({required this.contact});

  Map<String, dynamic> toJson() {
    return {'contact': contact};
  }
}

class RequestOtpResponse {
  final String challengeId;
  final bool isFirstLogin;
  final bool termsAccepted;

  RequestOtpResponse({
    required this.challengeId,
    required this.isFirstLogin,
    required this.termsAccepted,
  });

  factory RequestOtpResponse.fromJson(Map<String, dynamic> json) {
    return RequestOtpResponse(
      challengeId: json['challengeId'] as String? ?? '',
      isFirstLogin: json['isFirstLogin'] as bool? ?? false,
      termsAccepted: json['termsAccepted'] as bool? ?? false,
    );
  }
}

class VerifyOtpRequest {
  final String challengeId;
  final String otp;

  VerifyOtpRequest({
    required this.challengeId,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'otp': otp,
    };
  }
}

class VerifyOtpResponse {
  final bool isFirstLogin;
  final bool termsAccepted;
  final String? onboardingToken;
  final AuthCredentials? authCredentials;

  VerifyOtpResponse({
    required this.isFirstLogin,
    required this.termsAccepted,
    this.onboardingToken,
    this.authCredentials,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      isFirstLogin: json['isFirstLogin'] as bool? ?? false,
      termsAccepted: json['termsAccepted'] as bool? ?? false,
      onboardingToken: json['onboardingToken'] as String?,
      authCredentials: json['authCredentials'] != null
          ? AuthCredentials.fromJson(json['authCredentials'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AppAuthLoginRequest {
  final String email;
  final String password;

  AppAuthLoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class UserInfo {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String createdAt;

  UserInfo({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class AppAuthLoginResponse {
  final String refreshToken;
  final String accessToken;
  final String userId;
  final UserInfo? userInfo;

  AppAuthLoginResponse({
    required this.refreshToken,
    required this.accessToken,
    required this.userId,
    this.userInfo,
  });

  factory AppAuthLoginResponse.fromJson(Map<String, dynamic> json) {
    return AppAuthLoginResponse(
      refreshToken: json['refreshToken'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userInfo: json['userInfo'] != null
          ? UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GenerateAccessTokenRequest {
  final String userId;
  final String refreshToken;

  GenerateAccessTokenRequest({
    required this.userId,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'refreshToken': refreshToken,
    };
  }
}

class GenerateAccessTokenResponse {
  final String refreshToken;
  final String accessToken;

  GenerateAccessTokenResponse({
    required this.refreshToken,
    required this.accessToken,
  });

  factory GenerateAccessTokenResponse.fromJson(Map<String, dynamic> json) {
    return GenerateAccessTokenResponse(
      refreshToken: json['refreshToken'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
    );
  }
}
