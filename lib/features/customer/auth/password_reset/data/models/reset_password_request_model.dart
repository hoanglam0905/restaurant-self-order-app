class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.otp,
    required this.newPassword,
  });

  final String otp;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return {'otp': otp, 'newPassword': newPassword};
  }
}
