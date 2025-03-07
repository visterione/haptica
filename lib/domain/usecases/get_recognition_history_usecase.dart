import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../entities/recognition_result.dart';
import '../repositories/recognition_result_repository.dart';

/// Use case для отримання історії розпізнаних жестів
class GetRecognitionHistoryUseCase {
  /// Репозиторій результатів розпізнавання
  final RecognitionResultRepository _resultRepository;

  /// Конструктор
  GetRecognitionHistoryUseCase(this._resultRepository);

  /// Виконати use case
  Future<Either<Failure, List<RecognitionResult>>> execute(GetRecognitionHistoryParams params) async {
    try {
      if (params.limit != null) {
        return await _resultRepository.getLastResults(params.limit!);
      } else {
        return await _resultRepository.getResults();
      }
    } catch (e) {
      return Left(UnknownFailure(message: 'Помилка при отриманні історії розпізнавання: ${e.toString()}'));
    }
  }
}

/// Параметри для отримання історії розпізнаних жестів
class GetRecognitionHistoryParams extends Equatable {
  /// Кількість останніх результатів для отримання (null - всі результати)
  final int? limit;

  /// Конструктор
  const GetRecognitionHistoryParams({
    this.limit,
  });

  @override
  List<Object?> get props => [limit];
}