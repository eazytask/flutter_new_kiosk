
class AuthRequest {
  final String email;
  final String password;

  AuthRequest(this.email, this.password);

  Map<String, dynamic> toMap() => {
    "email": email,
    "password": password,
  };

  @override
  String toString() {
    return toMap().toString();
  }
}