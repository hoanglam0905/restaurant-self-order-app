class RegisterRequestModel {
  const RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.fullname,
    this.phone,
  });

  final String username;
  final String email;
  final String password;
  final String fullname;
  final String? phone;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'fullname': fullname,
    };
  }
}
