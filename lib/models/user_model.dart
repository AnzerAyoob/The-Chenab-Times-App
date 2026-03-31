import 'dart:convert';

class User {
  final int? id;
  final String username;
  final String passwordHash;
  final String? email;
  final String? dob;
  final String? gender;
  final String? address;
  final String? profilePicture;

  User({
    this.id,
    required this.username,
    required this.passwordHash,
    this.email,
    this.dob,
    this.gender,
    this.address,
    this.profilePicture,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      passwordHash: map['password_hash'],
      email: map['email'],
      dob: map['dob'],
      gender: map['gender'],
      address: map['address'],
      profilePicture: map['profile_picture'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'email': email,
      'dob': dob,
      'gender': gender,
      'address': address,
      'profile_picture': profilePicture,
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
