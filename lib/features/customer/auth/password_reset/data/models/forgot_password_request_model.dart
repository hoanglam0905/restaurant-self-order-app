class ForgotPasswordRequestModel {
  const ForgotPasswordRequestModel({
    required this.email,
    required this.username,
  });

  final String email;
  final String username;

  Map<String, dynamic> toJson() {
    return {'email': email, 'username': username};
  }
}
