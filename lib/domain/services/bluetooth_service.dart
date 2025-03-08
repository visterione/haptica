import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/utils/bluetooth_data_parser.dart';
import '../entities/sensor_data.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as dev_flutter_blue_plus;

/// Статус Bluetooth з'єднання
enum BluetoothConnectionStatus {
  /// Підключено
  connected,

  /// Відключено
  disconnected,

  /// В процесі підключення
  connecting,

  /// В процесі відключення
  disconnecting,

  /// Bluetooth вимкнено
  disabled,

  /// Немає дозволу
  unauthorized,
}

/// Клас, що представляє Bluetooth-пристрій
class BluetoothDevice {
  /// Адреса пристрою
  final String address;

  /// Назва пристрою
  final String? name;

  /// Нативний BluetoothDevice (flutter_blue_plus)
  final dynamic nativeDevice;

  /// Конструктор
  BluetoothDevice({
    required this.address,
    this.name,
    required this.nativeDevice
  });
}

/// Інтерфейс для сервісу роботи з Bluetooth
abstract class BluetoothManagerService {
  /// Отримати поточний статус з'єднання
  BluetoothConnectionStatus get status;

  /// Потік даних зі статусом з'єднання
  Stream<BluetoothConnectionStatus> get statusStream;

  /// Потік сенсорних даних від пристрою
  Stream<SensorData> get dataStream;

  /// Запит на дозволи, необхідні для роботи Bluetooth
  Future<bool> requestPermissions();

  /// Пошук доступних пристроїв
  Future<List<BluetoothDevice>> scanForDevices();

  /// Підключення до пристрою
  Future<bool> connectToDevice(BluetoothDevice device);

  /// Відключення від пристрою
  Future<bool> disconnect();

  /// Перевірка, чи доступний Bluetooth
  Future<bool> isBluetoothAvailable();

  /// Перевірка, чи увімкнений Bluetooth
  Future<bool> isBluetoothEnabled();

  /// Увімкнення Bluetooth (якщо можливо)
  Future<bool> enableBluetooth();
}

/// Реалізація сервісу Bluetooth з використанням flutter_blue_plus
class BluetoothManagerServiceImpl implements BluetoothManagerService {
  /// UUID сервісу для даних сенсорів (замініть на реальний UUID вашого пристрою)
  static const String SENSOR_SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";

  /// UUID характеристики для даних сенсорів (замініть на реальний UUID вашого пристрою)
  static const String SENSOR_CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  /// Інтервал сканування
  static const Duration SCAN_DURATION = Duration(seconds: 4);

  /// Підключений пристрій
  BluetoothDevice? _connectedDevice;

  /// Статус з'єднання
  BluetoothConnectionStatus _status = BluetoothConnectionStatus.disconnected;

  /// Контролер для потоку статусу
  final StreamController<BluetoothConnectionStatus> _statusController =
  StreamController<BluetoothConnectionStatus>.broadcast();

  /// Контролер для потоку даних сенсорів
  final StreamController<SensorData> _dataController =
  StreamController<SensorData>.broadcast();

  /// Підписка на потік даних
  StreamSubscription? _dataSubscription;

  /// Конструктор
  BluetoothManagerServiceImpl() {
    _initializeBluetooth();
  }

  /// Ініціалізація Bluetooth
  Future<void> _initializeBluetooth() async {
    // Підписка на зміни стану Bluetooth
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        if (_status == BluetoothConnectionStatus.disabled) {
          _updateStatus(BluetoothConnectionStatus.disconnected);
        }
      } else if (state == BluetoothAdapterState.off) {
        _updateStatus(BluetoothConnectionStatus.disabled);
      }
    });

    // Початкова перевірка стану
    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      _updateStatus(BluetoothConnectionStatus.disabled);
    }
  }

  @override
  BluetoothConnectionStatus get status => _status;

  @override
  Stream<BluetoothConnectionStatus> get statusStream => _statusController.stream;

  @override
  Stream<SensorData> get dataStream => _dataController.stream;

  /// Оновлення статусу з'єднання
  void _updateStatus(BluetoothConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
    }
  }

  @override
  Future<bool> requestPermissions() async {
    // Дозволи, які потрібні для Bluetooth на Android 12+
    List<Permission> permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ];

    // Запит дозволів
    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Перевірка, чи всі дозволи надані
    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });

    return allGranted;
  }

  @override
  Future<List<BluetoothDevice>> scanForDevices() async {
    List<BluetoothDevice> devices = [];

    // Перевірка, чи Bluetooth увімкнено
    if (!await isBluetoothEnabled()) {
      return devices;
    }

    _updateStatus(BluetoothConnectionStatus.disconnected);

    // Почати сканування
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    try {
      // Очікуємо результатів сканування
      var completer = Completer<List<BluetoothDevice>>();

      // Сканування з часовим обмеженням
      await FlutterBluePlus.startScan(timeout: SCAN_DURATION);

      // Отримуємо результати сканування
      List<ScanResult> scanResults = await FlutterBluePlus.scanResults.first;

      // Фільтрація і перетворення результатів
      for (ScanResult result in scanResults) {
        if (result.device.advName.isNotEmpty) {
          devices.add(BluetoothDevice(
            address: result.device.remoteId.str,
            name: result.device.advName,
            nativeDevice: result.device,
          ));
        }
      }

      return devices;
    } catch (e) {
      debugPrint('Помилка при скануванні Bluetooth: $e');
      return devices;
    } finally {
      // Зупинити сканування, якщо воно ще триває
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    }
  }

  @override
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_status == BluetoothConnectionStatus.connecting) {
      return false;
    }

    _updateStatus(BluetoothConnectionStatus.connecting);

    try {
      // Отримуємо нативний пристрій
      final nativeDevice = device.nativeDevice as dev_flutter_blue_plus.BluetoothDevice;

      // Підключення до пристрою
      await nativeDevice.connect(autoConnect: false);

      // Отримуємо сервіси
      List<BluetoothService> services = await nativeDevice.discoverServices();

      // Шукаємо наш сервіс і характеристику
      BluetoothService? sensorService;
      BluetoothCharacteristic? sensorCharacteristic;

      for (BluetoothService service in services) {
        if (service.uuid.toString() == SENSOR_SERVICE_UUID) {
          sensorService = service;
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == SENSOR_CHARACTERISTIC_UUID) {
              sensorCharacteristic = characteristic;
              break;
            }
          }
          break;
        }
      }

      // Перевіряємо, чи знайдені потрібні сервіс і характеристика
      if (sensorService == null || sensorCharacteristic == null) {
        throw Exception("Потрібні сервіси або характеристики не знайдені в пристрої");
      }

      // Підписуємося на отримання даних
      await sensorCharacteristic.setNotifyValue(true);
      _dataSubscription = sensorCharacteristic.onValueReceived.listen((data) {
        _handleSensorData(data);
      });

      // Зберігаємо підключений пристрій
      _connectedDevice = device;
      _updateStatus(BluetoothConnectionStatus.connected);

      return true;
    } catch (e) {
      debugPrint('Помилка підключення до Bluetooth: $e');
      await disconnect();
      return false;
    }
  }

  /// Обробка даних сенсорів
  void _handleSensorData(List<int> data) {
    try {
      // Використовуємо наш парсер для розбору даних від пристрою
      SensorData? sensorData = BluetoothDataParser.parseSensorData(data);

      if (sensorData != null) {
        // Надсилаємо дані через потік
        _dataController.add(sensorData);
      }
    } catch (e) {
      debugPrint('Помилка обробки даних сенсорів: $e');
    }
  }

  @override
  Future<bool> disconnect() async {
    if (_status == BluetoothConnectionStatus.disconnected) {
      return true;
    }

    _updateStatus(BluetoothConnectionStatus.disconnecting);

    try {
      // Відписуємося від потоку даних
      await _dataSubscription?.cancel();
      _dataSubscription = null;

      // Відключення від пристрою
      if (_connectedDevice != null) {
        final nativeDevice = _connectedDevice!.nativeDevice as dev_flutter_blue_plus.BluetoothDevice;
        await nativeDevice.disconnect();
      }

      _connectedDevice = null;
      _updateStatus(BluetoothConnectionStatus.disconnected);

      return true;
    } catch (e) {
      debugPrint('Помилка відключення Bluetooth: $e');
      _updateStatus(BluetoothConnectionStatus.disconnected);
      return false;
    }
  }

  @override
  Future<bool> isBluetoothAvailable() async {
    // Перевірка доступності Bluetooth
    final state = await FlutterBluePlus.adapterState.first;
    return state != BluetoothAdapterState.unavailable;
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    // Перевірка, чи увімкнений Bluetooth
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  @override
  Future<bool> enableBluetooth() async {
    // На iOS не можемо програмно увімкнути Bluetooth, лише запитати користувача
    try {
      await FlutterBluePlus.turnOn();
      return true;
    } catch (e) {
      debugPrint('Неможливо увімкнути Bluetooth програмно: $e');
      return false;
    }
  }

  /// Звільнення ресурсів
  void dispose() {
    _dataSubscription?.cancel();
    _statusController.close();
    _dataController.close();
  }
}