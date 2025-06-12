import 'dart:core';

class UserResponse {
  int id;
  String firstLastName;
  String phoneNumber;
  String email;
  String? profileImage;
  bool? isActive;
  String? status;
  DateTime? lastLogin;
  DateTime? createdAt;

  UserResponse({
    required this.id,
    required this.firstLastName,
    required this.phoneNumber,
    required this.email,
    this.profileImage,
    this.isActive,
    this.status,
    this.lastLogin,
    this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      firstLastName: json['firstLastName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      profileImage: json['profileImage'],
      isActive: json['active'],
      status: json['taskerStatus'],
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt:
          json['createAt'] != null ? DateTime.parse(json['createAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstLastName': firstLastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImage': profileImage,
      'active': isActive,
      'taskerStatus': status,
      'lastLogin': lastLogin?.toIso8601String(),
      'createAt': createdAt?.toIso8601String(),
    };
  }
}
