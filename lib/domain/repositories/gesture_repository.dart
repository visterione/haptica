import 'package:dartz/dartz.dart';
import '../entities/gesture.dart';
import '../../core/errors/failures.dart';

/// Інтерфейс для репозиторію жестів
abstract class GestureRepository {
  /// Отримати всі жести
  Future<Either<Failure, List<Gesture>>> getGestures();

  /// Отримати жест за ідентифікатором
  Future<Either<Failure, Gesture>> getGesture(int id);

  /// Зберегти жест
  Future<Either<Failure, Gesture>> saveGesture(Gesture gesture);

  /// Видалити жест
  Future<Either<Failure, bool>> deleteGesture(int id);

  /// Отримати жести за категорією
  Future<Either<Failure, List<Gesture>>> getGesturesByCategory(GestureCategory category);
}