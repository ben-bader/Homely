class AuthEntity {
  final String token;
  final String userId;
  final String email;
  final String name;
  final String role;

  const AuthEntity({
    required this.token,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });
}
