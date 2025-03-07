import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/recognition_result.dart';

/// Інтерфейс для репозиторію результатів розпізнавання
abstract class RecognitionResultRepository {
  /// Отримати всі результати розпізнавання
  Future<Either<Failure, List<RecognitionResult>>> getResults();

  /// Отримати результат за ідентифікатором
  Future<Either<Failure, RecognitionResult>> getResult(int id);

  /// Зберегти результат
  Future<Either<Failure, RecognitionResult>> saveResult(RecognitionResult result);

  /// Видалити результат
  Future<Either<Failure, bool>> deleteResult(int id);

  /// Отримати всі результати для конкретного жесту
  Future<Either<Failure, List<RecognitionResult>>> getResultsForGesture(int gestureId);

  /// Отримати останні N результатів
  Future<Either<Failure, List<RecognitionResult>>> getLastResults(int count);
}