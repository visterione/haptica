import '../../domain/entities/gesture.dart';

/// Модель жесту для роботи з даними
class GestureModel extends Gesture {
  /// Конструктор
  const GestureModel({
    int? id,
    required String name,
    required GestureCategory category,
    String? description,
    required DateTime createdAt,
  }) : super(
    id: id,
    name: name,
    category: category,
    description: description,
    createdAt: createdAt,
  );

  /// Створення моделі з карти (map)
  factory GestureModel.fromMap(Map<String, dynamic> map) {
    return GestureModel(
      id: map['gesture_id'],
      name: map['name'],
      category: GestureCategoryExtension.fromString(map['category'] ?? 'other'),
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  /// Перетворення моделі на карту (map)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'gesture_id': id,
      'name': name,
      'category': category.name.toLowerCase(),
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Створення моделі з сутності
  factory GestureModel.fromEntity(Gesture gesture) {
    return GestureModel(
      id: gesture.id,
      name: gesture.name,
      category: gesture.category,
      description: gesture.description,
      createdAt: gesture.createdAt,
    );
  }
}