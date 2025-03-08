// lib/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<domain.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<Either<Failure, domain.User>> signInWithGoogle() async {
    try {
      print('Починаємо Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Користувач скасував процес входу');
        return Left(AuthFailure(message: 'Вхід було скасовано'));
      }

      print('Отримано Google акаунт: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Отримано токени автентифікації Google');
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        print('Створено Firebase credential, виконуємо вхід...');
        final userCredential = await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = userCredential.user;

        if (firebaseUser == null) {
          print('Firebase повернув null користувача');
          return Left(AuthFailure(message: 'Не вдалося отримати дані користувача'));
        }

        print('Успішний вхід користувача: ${firebaseUser.email}');

        // Безпечне створення моделі користувача
        try {
          final user = UserModel.fromFirebaseUser(firebaseUser);
          return Right(user);
        } catch (modelError) {
          print('Помилка створення моделі користувача: $modelError');
          // Створюємо базову модель з мінімумом даних, якщо звичайний спосіб не працює
          return Right(UserModel(
            id: firebaseUser.uid,
            displayName: firebaseUser.displayName,
            email: firebaseUser.email,
            photoUrl: firebaseUser.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          ));
        }
      } catch (firebaseError) {
        print('Помилка Firebase Auth: $firebaseError');
        return Left(AuthFailure(message: 'Помилка Firebase Auth: $firebaseError'));
      }
    } catch (e) {
      print('Детальна помилка під час входу через Google: ${e.toString()}');
      return Left(AuthFailure(message: 'Помилка під час входу через Google: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Right(true);
    } catch (e) {
      return Left(AuthFailure(message: 'Помилка під час виходу з облікового запису: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.User?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const Right(null);
      }
      return Right(UserModel.fromFirebaseUser(firebaseUser));
    } catch (e) {
      return Left(AuthFailure(message: 'Помилка отримання поточного користувача: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserSignedIn() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      return Right(firebaseUser != null);
    } catch (e) {
      return Left(AuthFailure(message: 'Помилка перевірки стану входу: ${e.toString()}'));
    }
  }
}