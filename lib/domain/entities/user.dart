// lib/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const User({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
  });

  @override
  List<Object?> get props => [id, displayName, email, photoUrl, createdAt, lastLoginAt];

  User copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}