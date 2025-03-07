import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/gesture.dart';
import '../../domain/repositories/gesture_repository.dart';
import '../datasources/database_helper.dart';
import '../models/gesture_model.dart';

/// Реалізація репозиторію жестів
class GestureRepositoryImpl implements GestureRepository {
  /// Екземпляр класу для роботи з базою даних
  final DatabaseHelper _databaseHelper;

  /// Конструктор
  GestureRepositoryImpl(this._databaseHelper);

  @override
  Future<Either<Failure, List<Gesture>>> getGestures() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(DatabaseHelper.tableGestures);

      final gestures = result.map((map) => GestureModel.fromMap(map)).toList();
      return Right(gestures);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося отримати жести: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Gesture>> getGesture(int id) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableGestures,
        where: 'gesture_id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        return Left(DatabaseFailure(message: 'Жест з ID $id не знайдено'));
      }

      return Right(GestureModel.fromMap(result.first));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося отримати жест: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Gesture>> saveGesture(Gesture gesture) async {
    try {
      final db = await _databaseHelper.database;
      final gestureModel = GestureModel.fromEntity(gesture);

      int id;
      if (gesture.id == null) {
        // Створення нового жесту
        id = await db.insert(DatabaseHelper.tableGestures, gestureModel.toMap());
      } else {
        // Оновлення існуючого жесту
        await db.update(
          DatabaseHelper.tableGestures,
          gestureModel.toMap(),
          where: 'gesture_id = ?',
          whereArgs: [gesture.id],
        );
        id = gesture.id!;
      }

      // Отримання оновленого жесту
      final updatedGesture = await getGesture(id);
      return updatedGesture;
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося зберегти жест: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteGesture(int id) async {
    try {
      final db = await _databaseHelper.database;
      final deletedCount = await db.delete(
        DatabaseHelper.tableGestures,
        where: 'gesture_id = ?',
        whereArgs: [id],
      );

      return Right(deletedCount > 0);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося видалити жест: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Gesture>>> getGesturesByCategory(GestureCategory category) async {
    try {
      final db = await _databaseHelper.database;
      final categoryStr = category.name.toLowerCase();

      final result = await db.query(
        DatabaseHelper.tableGestures,
        where: 'category = ?',
        whereArgs: [categoryStr],
      );

      final gestures = result.map((map) => GestureModel.fromMap(map)).toList();
      return Right(gestures);
    } catch (e) {
      return Left(DatabaseFailure(
          message: 'Не вдалося отримати жести для категорії ${category.name}: ${e.toString()}'
      ));
    }
  }
}