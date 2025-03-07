import 'package:equatable/equatable.dart';

/// Категорія жесту
enum GestureCategory {
  /// Літера
  letter,

  /// Цифра
  number,

  /// Загальний жест
  general,

  /// Інше
  other,
}

/// Сутність жесту
class Gesture extends Equatable {
  /// Унікальний ідентифікатор жесту
  final int? id;

  /// Назва жесту
  final String name;

  /// Категорія жесту
  final GestureCategory category;

  /// Опис жесту
  final String? description;

  /// Час створення
  final DateTime createdAt;

  /// Конструктор
  const Gesture({
    this.id,
    required this.name,
    required this.category,
    this.description,
    required this.createdAt,
  });

  /// Створення копії з новими значеннями
  Gesture copyWith({
    int? id,
    String? name,
    GestureCategory? category,
    String? description,
    DateTime? createdAt,
  }) {
    return Gesture(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, category, description, createdAt];

  @override
  String toString() => 'Gesture { id: $id, name: $name, category: $category }';
}

/// Розширення для категорії жестів
extension GestureCategoryExtension on GestureCategory {
  /// Отримати назву категорії
  String get name {
    switch (this) {
      case GestureCategory.letter:
        return 'Літера';
      case GestureCategory.number:
        return 'Цифра';
      case GestureCategory.general:
        return 'Загальний';
      case GestureCategory.other:
        return 'Інше';
    }
  }

  /// Отримати категорію за назвою
  static GestureCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'літера':
      case 'letter':
        return GestureCategory.letter;
      case 'цифра':
      case 'number':
        return GestureCategory.number;
      case 'загальний':
      case 'general':
        return GestureCategory.general;
      default:
        return GestureCategory.other;
    }
  }
}