import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? photoURL;
  final String? gender;
  final DateTime? birthDate;
  final String? phone;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.photoURL,
    this.gender,
    this.birthDate,
    this.phone,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'],
      photoURL: data['photoURL'],
      gender: data['gender'],
      birthDate: data['birthDate'] != null 
          ? (data['birthDate'] as Timestamp).toDate() 
          : null,
      phone: data['phone'],
      bio: data['bio'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'gender': gender,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'phone': phone,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'photoURL': photoURL,
      'gender': gender,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'phone': phone,
      'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(), 
    };
  }

  AppUser copyWith({
    String? name,
    String? photoURL,
    String? gender,
    DateTime? birthDate,
    String? phone,
    String? bio,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}