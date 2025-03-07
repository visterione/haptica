import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Дані акселерометра
class AccelerometerData extends Equatable {
  /// Прискорення по осі X
  final double x;

  /// Прискорення по осі Y
  final double y;

  /// Прискорення по осі Z
  final double z;

  /// Конструктор
  const AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
  });

  /// Створення з JSON мапи
  factory AccelerometerData.fromJson(Map<String, dynamic> json) {
    return AccelerometerData(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      z: json['z'].toDouble(),
    );
  }

  /// Конвертація в JSON мапу
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  @override
  List<Object> get props => [x, y, z];

  @override
  String toString() => 'AccelerometerData { x: $x, y: $y, z: $z }';
}

/// Дані гіроскопа
class GyroscopeData extends Equatable {
  /// Кутова швидкість по осі X
  final double x;

  /// Кутова швидкість по осі Y
  final double y;

  /// Кутова швидкість по осі Z
  final double z;

  /// Конструктор
  const GyroscopeData({
    required this.x,
    required this.y,
    required this.z,
  });

  /// Створення з JSON мапи
  factory GyroscopeData.fromJson(Map<String, dynamic> json) {
    return GyroscopeData(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      z: json['z'].toDouble(),
    );
  }

  /// Конвертація в JSON мапу
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  @override
  List<Object> get props => [x, y, z];

  @override
  String toString() => 'GyroscopeData { x: $x, y: $y, z: $z }';
}

/// Дані сенсорів згину пальців
class FlexSensorData extends Equatable {
  /// Список значень згину пальців (від 0.0 до 1.0)
  final List<double> values;

  /// Конструктор
  const FlexSensorData({
    required this.values,
  });

  /// Створення з JSON мапи
  factory FlexSensorData.fromJson(Map<String, dynamic> json) {
    List<dynamic> dynamicList = json['values'] as List<dynamic>;
    List<double> doubleList = dynamicList.map<double>((dynamic value) {
      if (value is double) {
        return value;
      } else if (value is int) {
        return value.toDouble();
      } else if (value is String) {
        return double.parse(value);
      }
      // Для інших випадків встановлюємо 0.0 як значення за замовчуванням
      return 0.0;
    }).toList();

    return FlexSensorData(
      values: doubleList,
    );
  }

  /// Конвертація в JSON мапу
  Map<String, dynamic> toJson() {
    return {
      'values': values,
    };
  }

  /// Отримання значення згину для конкретного пальця
  double getFingerValue(int fingerIndex) {
    if (fingerIndex < 0 || fingerIndex >= values.length) {
      throw RangeError('Недійсний індекс пальця: $fingerIndex');
    }
    return values[fingerIndex];
  }

  @override
  List<Object> get props => [values];

  @override
  String toString() => 'FlexSensorData { values: $values }';
}

/// Повний набір даних з усіх сенсорів
class SensorData extends Equatable {
  /// Дані акселерометра
  final AccelerometerData accelerometer;

  /// Дані гіроскопа
  final GyroscopeData gyroscope;

  /// Дані сенсорів згину
  final FlexSensorData flexSensors;

  /// Часова мітка отримання даних
  final DateTime timestamp;

  /// Конструктор
  const SensorData({
    required this.accelerometer,
    required this.gyroscope,
    required this.flexSensors,
    required this.timestamp,
  });

  /// Створення з JSON рядка
  factory SensorData.fromJsonString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return SensorData.fromJson(json);
  }

  /// Створення з JSON мапи
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      accelerometer: AccelerometerData.fromJson(json['accelerometer']),
      gyroscope: GyroscopeData.fromJson(json['gyroscope']),
      flexSensors: FlexSensorData.fromJson(json['flexSensors']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  /// Конвертація в JSON мапу
  Map<String, dynamic> toJson() {
    return {
      'accelerometer': accelerometer.toJson(),
      'gyroscope': gyroscope.toJson(),
      'flexSensors': flexSensors.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Конвертація в JSON рядок
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Перетворення на плоский список числових значень для ML моделі
  List<double> toMLInputFeatures() {
    List<double> features = [];

    // Дані акселерометра
    features.add(accelerometer.x);
    features.add(accelerometer.y);
    features.add(accelerometer.z);

    // Дані гіроскопа
    features.add(gyroscope.x);
    features.add(gyroscope.y);
    features.add(gyroscope.z);

    // Дані сенсорів згину
    features.addAll(flexSensors.values);

    return features;
  }

  @override
  List<Object> get props => [accelerometer, gyroscope, flexSensors, timestamp];

  @override
  String toString() => 'SensorData { timestamp: $timestamp }';
}