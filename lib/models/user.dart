class User {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String avatar;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name'],
      email: json['email'],
      password: json['password'],
      avatar: json['avatar'] ?? '',
    );
  }
}