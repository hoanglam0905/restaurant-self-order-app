class VerifyRegisterOtpRequestModel {
  const VerifyRegisterOtpRequestModel({required this.email, required this.otp});

  final String email;
  final String otp;

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}
