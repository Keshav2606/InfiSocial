enum Gender { male, female, other }

class User {
  const User({
    this.userId = '',
    required this.username,
    required this.fullname,
    required this.email,
    required this.age,
    required this.gender,
    this.bio = '',
    this.avatar = '',
  });

  final String userId;
  final String username;
  final String fullname;
  final String email;
  final int age;
  final String gender;
  final String bio;
  final String avatar;
}
