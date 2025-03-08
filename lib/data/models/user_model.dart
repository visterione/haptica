// lib/data/models/user_model.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart' as domain;

class UserModel extends domain.User {
  const UserModel({
    required String id,
    String? displayName,
    String? email,
    String? photoUrl,
    required DateTime createdAt,
    required DateTime lastLoginAt,
  }) : super(
    id: id,
    displayName: displayName,
    email: email,
    photoUrl: photoUrl,
    createdAt: createdAt,
    lastLoginAt: lastLoginAt,
  );

  /// Створення з Firebase User
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  /// Створення з JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      displayName: json['display_name'],
      email: json['email'],
      photoUrl: json['photo_url'],
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: DateTime.parse(json['last_login_at']),
    );
  }

  /// Конвертація в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
    };
  }
}