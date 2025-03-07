import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../entities/recognition_result.dart';
import '../entities/sensor_data.dart';
import '../repositories/gesture_repository.dart';
import '../repositories/recognition_result_repository.dart';
import '../services/ml_service.dart';

/// Use case для розпізнавання жесту
class RecognizeGestureUseCase {
  /// Репозиторій жестів
  final GestureRepository _gestureRepository;

  /// Репозиторій результатів розпізнавання
  final RecognitionResultRepository _resultRepository;

  /// Сервіс ML для розпізнавання
  final MLService _mlService;

  /// Конструктор
  RecognizeGestureUseCase(
      this._gestureRepository,
      this._resultRepository,
      this._mlService,
      );

  /// Виконати use case
  Future<Either<Failure, RecognitionResult>> execute(RecognizeGestureParams params) async {
    try {
      // Отримуємо всі жести з бази даних
      final gesturesResult = await _gestureRepository.getGestures();

      return await gesturesResult.fold(
            (failure) => Left(failure),
            (gestures) async {
          // Розпізнаємо жест за допомогою ML сервісу
          final recognitionResult = await _mlService.recognizeGesture(params.sensorData, gestures);

          if (recognitionResult == null) {
            return Left(RecognitionFailure(message: 'Не вдалося розпізнати жест'));
          }

          // Зберігаємо результат у базу даних, якщо потрібно
          if (params.saveResult) {
            final savedResult = await _resultRepository.saveResult(recognitionResult);
            return savedResult;
          }

          return Right(recognitionResult);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Помилка при розпізнаванні жесту: ${e.toString()}'));
    }
  }
}

/// Параметри для розпізнавання жесту
class RecognizeGestureParams extends Equatable {
  /// Дані сенсорів
  final SensorData sensorData;

  /// Чи зберігати результат у базу даних
  final bool saveResult;

  /// Конструктор
  const RecognizeGestureParams({
    required this.sensorData,
    this.saveResult = true,
  });

  @override
  List<Object?> get props => [sensorData, saveResult];
}