// import 'package:flutter/material.dart';

enum Gender { male, female, other }

class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final String? age;
  final String? gender;
  final List<String> followers;
  final List<String> following;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.bio,
    this.avatarUrl,
    this.age,
    this.gender,
    this.followers = const [],
    this.following = const [],
  });

  // Factory method to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // debugPrint("UserModel.fromJson: $json");
    final _user = UserModel(
      id: json['_id'].toString(),
      firstName: json['firstName'],
      lastName: json['lastName'] ?? '',
      username: json['username'],
      email: json['email'],
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      age: json['age'] != null ? json['age'].toString() : '',
      gender: json['gender'] ?? '',
      followers: List<String>.from(json['followers']),
      following: List<String>.from(json['following']),
    );
    // debugPrint("User in user model: $_user");
    return _user;
  }

  // Convert UserModel to JSON (for sending to backend)
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "email": email,
      "bio": bio,
      "avatarUrl": avatarUrl,
      "age": age,
      "gender": gender,
      "followers": followers,
      "following": following,
    };
  }
}
