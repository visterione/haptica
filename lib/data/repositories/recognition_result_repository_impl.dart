import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/recognition_result.dart';
import '../../domain/repositories/gesture_repository.dart';
import '../../domain/repositories/recognition_result_repository.dart';
import '../datasources/database_helper.dart';
import '../models/recognition_result_model.dart';

/// Реалізація репозиторію результатів розпізнавання
class RecognitionResultRepositoryImpl implements RecognitionResultRepository {
  /// Екземпляр класу для роботи з базою даних
  final DatabaseHelper _databaseHelper;

  /// Репозиторій жестів (для отримання інформації про жести)
  final GestureRepository _gestureRepository;

  /// Конструктор
  RecognitionResultRepositoryImpl(this._databaseHelper, this._gestureRepository);

  @override
  Future<Either<Failure, List<RecognitionResult>>> getResults() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(DatabaseHelper.tableRecognitionResults);

      final results = <RecognitionResult>[];

      for (var map in result) {
        final gestureId = map['gesture_id'] as int;
        final gestureResult = await _gestureRepository.getGesture(gestureId);

        await gestureResult.fold(
              (failure) {
            throw Exception('Не вдалося отримати жест: ${failure.message}');
          },
              (gesture) async {
            final recognitionResult = RecognitionResultModel.fromMap(map, gesture);
            results.add(recognitionResult);
          },
        );
      }

      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося отримати результати розпізнавання: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, RecognitionResult>> getResult(int id) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableRecognitionResults,
        where: 'result_id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        return Left(DatabaseFailure(message: 'Результат з ID $id не знайдено'));
      }

      final map = result.first;
      final gestureId = map['gesture_id'] as int;
      final gestureResult = await _gestureRepository.getGesture(gestureId);

      return gestureResult.fold(
            (failure) => Left(failure),
            (gesture) => Right(RecognitionResultModel.fromMap(map, gesture)),
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося отримати результат: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, RecognitionResult>> saveResult(RecognitionResult result) async {
    try {
      final db = await _databaseHelper.database;
      final resultModel = RecognitionResultModel.fromEntity(result);

      int id;
      if (result.id == null) {
        // Створення нового результату
        id = await db.insert(DatabaseHelper.tableRecognitionResults, resultModel.toMap());
      } else {
        // Оновлення існуючого результату
        await db.update(
          DatabaseHelper.tableRecognitionResults,
          resultModel.toMap(),
          where: 'result_id = ?',
          whereArgs: [result.id],
        );
        id = result.id!;
      }

      // Оновлення статистики
      await _updateStatistics(result.gesture.id!, result.confidence);

      // Отримання оновленого результату
      final updatedResult = await getResult(id);
      return updatedResult;
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося зберегти результат: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteResult(int id) async {
    try {
      final db = await _databaseHelper.database;
      final deletedCount = await db.delete(
        DatabaseHelper.tableRecognitionResults,
        where: 'result_id = ?',
        whereArgs: [id],
      );

      return Right(deletedCount > 0);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося видалити результат: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<RecognitionResult>>> getResultsForGesture(int gestureId) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableRecognitionResults,
        where: 'gesture_id = ?',
        whereArgs: [gestureId],
      );

      final gestureResult = await _gestureRepository.getGesture(gestureId);

      return gestureResult.fold(
            (failure) => Left(failure),
            (gesture) {
          final results = result.map((map) => RecognitionResultModel.fromMap(map, gesture)).toList();
          return Right(results);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(
          message: 'Не вдалося отримати результати для жесту з ID $gestureId: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, List<RecognitionResult>>> getLastResults(int count) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableRecognitionResults,
        orderBy: 'timestamp DESC',
        limit: count,
      );

      final results = <RecognitionResult>[];

      for (var map in result) {
        final gestureId = map['gesture_id'] as int;
        final gestureResult = await _gestureRepository.getGesture(gestureId);

        await gestureResult.fold(
              (failure) {
            throw Exception('Не вдалося отримати жест: ${failure.message}');
          },
              (gesture) async {
            final recognitionResult = RecognitionResultModel.fromMap(map, gesture);
            results.add(recognitionResult);
          },
        );
      }

      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(
          message: 'Не вдалося отримати останні $count результатів: ${e.toString()}'
      ));
    }
  }

  /// Оновлення статистики розпізнавання
  Future<void> _updateStatistics(int gestureId, double confidence) async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now().toIso8601String();

      // Перевірка, чи існує запис для цього жесту
      final existingStats = await db.query(
        DatabaseHelper.tableRecognitionStatistics,
        where: 'gesture_id = ?',
        whereArgs: [gestureId],
      );

      if (existingStats.isEmpty) {
        // Створення нового запису статистики
        await db.insert(
          DatabaseHelper.tableRecognitionStatistics,
          {
            'gesture_id': gestureId,
            'total_attempts': 1,
            'successful_attempts': confidence >= 0.85 ? 1 : 0,
            'average_confidence': confidence,
            'last_updated': now,
          },
        );
      } else {
        // Оновлення існуючого запису
        final existingStat = existingStats.first;
        final totalAttempts = (existingStat['total_attempts'] as int) + 1;
        final successfulAttempts = (existingStat['successful_attempts'] as int) + (confidence >= 0.85 ? 1 : 0);
        final oldAvgConfidence = existingStat['average_confidence'] as double?;

        // Обчислення нового середнього рівня впевненості
        final newAvgConfidence = oldAvgConfidence == null
            ? confidence
            : (oldAvgConfidence * (totalAttempts - 1) + confidence) / totalAttempts;

        await db.update(
          DatabaseHelper.tableRecognitionStatistics,
          {
            'total_attempts': totalAttempts,
            'successful_attempts': successfulAttempts,
            'average_confidence': newAvgConfidence,
            'last_updated': now,
          },
          where: 'gesture_id = ?',
          whereArgs: [gestureId],
        );
      }
    } catch (e) {
      print('Помилка при оновленні статистики: ${e.toString()}');
    }
  }
}