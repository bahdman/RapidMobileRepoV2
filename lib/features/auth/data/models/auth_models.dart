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
