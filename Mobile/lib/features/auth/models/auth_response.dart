class AuthResponse {
  final String token;
  final String userId;
  final String email;
  final String role;
  final String firstName;
  final String lastName;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }
}
