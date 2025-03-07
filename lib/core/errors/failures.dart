import 'package:equatable/equatable.dart';

/// Базовий клас для всіх помилок в додатку
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Помилка сервера
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Помилка бази даних
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Помилка Bluetooth
class BluetoothFailure extends Failure {
  const BluetoothFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Помилка розпізнавання
class RecognitionFailure extends Failure {
  const RecognitionFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Помилка мережі
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Помилка аутентифікації
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Помилка кешу
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Невідома помилка
class UnknownFailure extends Failure {
  const UnknownFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}