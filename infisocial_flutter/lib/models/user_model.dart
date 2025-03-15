enum Gender {male, female, other}

class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final String age;
  final String gender;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.bio,
    this.avatarUrl,
    required this.age,
    required this.gender,
  });

  // Factory method to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'] ?? '',
      username: json['username'],
      email: json['email'],
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      age: json['age'] ? json['age'].toString() : '',
      gender: json['gender'] ?? '',
    );
  }

  // Convert UserModel to JSON (for sending to backend)
  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "email": email,
      "bio": bio,
      "avatarUrl": avatarUrl,
      "age": age,
      "gender": gender,
    };
  }
}
