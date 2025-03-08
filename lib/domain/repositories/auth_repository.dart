// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, bool>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isUserSignedIn();
}