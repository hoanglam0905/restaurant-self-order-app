class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.username,
    required this.email,
    required this.userType,
    this.staffId,
    this.customerId,
    this.points,
    this.fullName,
    this.message,
  });

  final String accessToken;
  final String refreshToken;
  final String username;
  final String email;
  final String userType;
  final int? staffId;
  final int? customerId;
  final int? points;
  final String? fullName;
  final String? message;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      userType: json['userType'] as String? ?? '',
      staffId: (json['staffId'] as num?)?.toInt(),
      customerId: (json['customerId'] as num?)?.toInt(),
      points: (json['points'] as num?)?.toInt(),
      fullName: json['fullname'] as String?,
      message: json['message'] as String?,
    );
  }
}
