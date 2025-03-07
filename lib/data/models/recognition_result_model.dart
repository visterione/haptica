import '../../domain/entities/gesture.dart';
import '../../domain/entities/recognition_result.dart';

/// Модель результату розпізнавання для роботи з даними
class RecognitionResultModel extends RecognitionResult {
  /// Конструктор
  const RecognitionResultModel({
    int? id,
    required Gesture gesture,
    required double confidence,
    String? rawData,
    required DateTime timestamp,
  }) : super(
    id: id,
    gesture: gesture,
    confidence: confidence,
    rawData: rawData,
    timestamp: timestamp,
  );

  /// Створення моделі з карти (map) і жесту
  factory RecognitionResultModel.fromMap(Map<String, dynamic> map, Gesture gesture) {
    return RecognitionResultModel(
      id: map['result_id'],
      gesture: gesture,
      confidence: map['confidence'],
      rawData: map['raw_data'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  /// Перетворення моделі на карту (map)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'result_id': id,
      'gesture_id': gesture.id,
      'confidence': confidence,
      'raw_data': rawData,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Створення моделі з сутності
  factory RecognitionResultModel.fromEntity(RecognitionResult result) {
    return RecognitionResultModel(
      id: result.id,
      gesture: result.gesture,
      confidence: result.confidence,
      rawData: result.rawData,
      timestamp: result.timestamp,
    );
  }
}