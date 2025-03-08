// lib/presentation/viewmodels/auth_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authStateSubscription;

  AuthViewModel(this._authRepository) {
    _init();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  void _init() {
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.getCurrentUser();
    result.fold(
          (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
          (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.signInWithGoogle();
    return result.fold(
          (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
          (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.signOut();
    return result.fold(
          (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
          (_) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}