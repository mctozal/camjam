import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final int? age;
  final Timestamp createdAt;
  final String gender;
  String id;
  final String username;
  String? selectedImage = '';

  User({
    required this.age,
    required this.createdAt,
    required this.gender,
    required this.id,
    required this.username,
    this.selectedImage,
  });

  // Convert User model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'createdAt': createdAt,
      'gender': gender,
      'id': id,
      'username': username,
      'selectedImage': selectedImage,
    };
  }

  // Convert Firestore document to User model
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      age: data['age'],
      createdAt: data['createdAt'],
      gender: data['gender'],
      id: data['id'],
      username: data['username'],
      selectedImage: data['selectedImage'],
    );
  }
}
