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
    this.fullname,
  });

  final String accessToken;
  final String refreshToken;
  final String username;
  final String email;
  final String userType;
  final int? staffId;
  final int? customerId;
  final int? points;
  final String? fullname;

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
      fullname: json['fullname'] as String?,
    );
  }
}
