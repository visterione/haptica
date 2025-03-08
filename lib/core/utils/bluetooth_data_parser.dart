import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../domain/entities/sensor_data.dart';

/// Утилітний клас для парсингу даних з Bluetooth-пристрою
class BluetoothDataParser {
  /// Парсинг даних з Bluetooth-пристрою
  static SensorData? parseSensorData(List<int> rawData) {
    try {
      // Спроба парсингу як JSON
      try {
        String jsonString = String.fromCharCodes(rawData);
        return _parseJsonData(jsonString);
      } catch (jsonError) {
        debugPrint('Не вдалося розпарсити дані як JSON: $jsonError');
      }

      // Спроба парсингу як бінарні дані
      try {
        return _parseBinaryData(rawData);
      } catch (binaryError) {
        debugPrint('Не вдалося розпарсити дані як бінарні: $binaryError');
      }

      // Якщо не вдалося розпарсити ні як JSON, ні як бінарні дані
      debugPrint('Формат даних від пристрою не розпізнано');
      return null;
    } catch (e) {
      debugPrint('Помилка парсингу даних сенсорів: $e');
      return null;
    }
  }

  /// Парсинг даних у форматі JSON
  static SensorData _parseJsonData(String jsonString) {
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    // Перевірка наявності необхідних полів
    if (!jsonData.containsKey('accel') ||
        !jsonData.containsKey('gyro') ||
        !jsonData.containsKey('flex')) {
      throw FormatException('Відсутні необхідні поля в JSON даних');
    }

    // Парсинг даних акселерометра
    Map<String, dynamic> accelMap = jsonData['accel'];
    double accelX = accelMap['x']?.toDouble() ?? 0.0;
    double accelY = accelMap['y']?.toDouble() ?? 0.0;
    double accelZ = accelMap['z']?.toDouble() ?? 0.0;
    AccelerometerData accelerometerData = AccelerometerData(x: accelX, y: accelY, z: accelZ);

    // Парсинг даних гіроскопа
    Map<String, dynamic> gyroMap = jsonData['gyro'];
    double gyroX = gyroMap['x']?.toDouble() ?? 0.0;
    double gyroY = gyroMap['y']?.toDouble() ?? 0.0;
    double gyroZ = gyroMap['z']?.toDouble() ?? 0.0;
    GyroscopeData gyroscopeData = GyroscopeData(x: gyroX, y: gyroY, z: gyroZ);

    // Парсинг даних сенсорів згинання
    List<dynamic> flexJson = jsonData['flex'];
    // Виправляємо помилку конвертування
    List<double> flexValues = flexJson.map((value) => (value as num).toDouble()).toList();
    FlexSensorData flexSensorData = FlexSensorData(values: flexValues);

    // Створення повного об'єкта даних
    return SensorData(
      accelerometer: accelerometerData,
      gyroscope: gyroscopeData,
      flexSensors: flexSensorData,
      timestamp: DateTime.now(),
    );
  }

  /// Парсинг бінарних даних (приклад, потрібно адаптувати під реальний формат даних)
  static SensorData _parseBinaryData(List<int> rawData) {
    // Створюємо ByteData для легшого читання типізованих значень
    final byteData = ByteData.view(Uint8List.fromList(rawData).buffer);

    // Зміщення в байтах для читання даних
    int offset = 0;

    // Читаємо дані акселерометра (3 float значення)
    double accelX = byteData.getFloat32(offset, Endian.little);
    offset += 4;
    double accelY = byteData.getFloat32(offset, Endian.little);
    offset += 4;
    double accelZ = byteData.getFloat32(offset, Endian.little);
    offset += 4;

    // Читаємо дані гіроскопа (3 float значення)
    double gyroX = byteData.getFloat32(offset, Endian.little);
    offset += 4;
    double gyroY = byteData.getFloat32(offset, Endian.little);
    offset += 4;
    double gyroZ = byteData.getFloat32(offset, Endian.little);
    offset += 4;

    // Читаємо кількість сенсорів згинання
    int numFlexSensors = byteData.getUint8(offset);
    offset += 1;

    // Читаємо значення сенсорів згинання
    List<double> flexValues = [];
    for (int i = 0; i < numFlexSensors; i++) {
      flexValues.add(byteData.getFloat32(offset, Endian.little));
      offset += 4;
    }

    // Створюємо об'єкти даних
    AccelerometerData accelerometerData = AccelerometerData(x: accelX, y: accelY, z: accelZ);
    GyroscopeData gyroscopeData = GyroscopeData(x: gyroX, y: gyroY, z: gyroZ);
    FlexSensorData flexSensorData = FlexSensorData(values: flexValues);

    // Створюємо повний об'єкт даних
    return SensorData(
      accelerometer: accelerometerData,
      gyroscope: gyroscopeData,
      flexSensors: flexSensorData,
      timestamp: DateTime.now(),
    );
  }
}