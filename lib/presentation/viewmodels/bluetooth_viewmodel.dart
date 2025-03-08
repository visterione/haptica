import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/sensor_data.dart';
// Імпортуємо з аліасом, щоб уникнути конфліктів імен
import '../../domain/services/bluetooth_service.dart' as app_bluetooth;

/// ViewModel для роботи з Bluetooth
class BluetoothViewModel extends ChangeNotifier {
  /// Сервіс Bluetooth
  final app_bluetooth.BluetoothManagerService _bluetoothService;

  /// Список доступних пристроїв
  List<app_bluetooth.BluetoothDevice> _devices = [];

  /// Поточний статус підключення
  app_bluetooth.BluetoothConnectionStatus _connectionStatus = app_bluetooth.BluetoothConnectionStatus.disconnected;

  /// Обраний пристрій
  app_bluetooth.BluetoothDevice? _selectedDevice;

  /// Прапорець сканування
  bool _isScanning = false;

  /// Підписки на потоки
  final List<StreamSubscription> _subscriptions = [];

  /// Останні отримані дані сенсорів
  SensorData? _lastSensorData;

  /// Обробник для нових даних сенсорів
  Function(SensorData)? onNewSensorData;

  /// Конструктор
  BluetoothViewModel(this._bluetoothService) {
    _init();
  }

  /// Ініціалізація
  void _init() {
    // Підписка на зміни статусу
    _subscriptions.add(
        _bluetoothService.statusStream.listen((status) {
          _connectionStatus = status;
          notifyListeners();
        })
    );

    // Підписка на потік даних
    _subscriptions.add(
        _bluetoothService.dataStream.listen((data) {
          _lastSensorData = data;
          onNewSensorData?.call(data);
          notifyListeners();
        })
    );
  }

  /// Список доступних пристроїв
  List<app_bluetooth.BluetoothDevice> get devices => _devices;

  /// Поточний статус підключення
  app_bluetooth.BluetoothConnectionStatus get connectionStatus => _connectionStatus;

  /// Обраний пристрій
  app_bluetooth.BluetoothDevice? get selectedDevice => _selectedDevice;

  /// Прапорець сканування
  bool get isScanning => _isScanning;

  /// Останні отримані дані сенсорів
  SensorData? get lastSensorData => _lastSensorData;

  /// Перевірка, чи підключено пристрій
  bool get isConnected => _connectionStatus == app_bluetooth.BluetoothConnectionStatus.connected;

  /// Перевірка дозволів Bluetooth
  Future<bool> checkPermissions() async {
    return await _bluetoothService.requestPermissions();
  }

  /// Пошук доступних пристроїв
  Future<void> scanForDevices() async {
    if (_isScanning) return;

    try {
      _isScanning = true;
      notifyListeners();

      // Перевіряємо, чи увімкнений Bluetooth
      if (!await _bluetoothService.isBluetoothEnabled()) {
        await _bluetoothService.enableBluetooth();
      }

      // Сканування пристроїв
      _devices = await _bluetoothService.scanForDevices();

      _isScanning = false;
      notifyListeners();
    } catch (e) {
      _isScanning = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Підключення до пристрою
  Future<bool> connectToDevice(app_bluetooth.BluetoothDevice device) async {
    _selectedDevice = device;
    notifyListeners();

    final result = await _bluetoothService.connectToDevice(device);
    notifyListeners();
    return result;
  }

  /// Відключення від пристрою
  Future<bool> disconnect() async {
    final result = await _bluetoothService.disconnect();
    _selectedDevice = null;
    notifyListeners();
    return result;
  }

  /// Отримання назви статусу підключення
  String getStatusName() {
    switch (_connectionStatus) {
      case app_bluetooth.BluetoothConnectionStatus.connected:
        return 'Підключено';
      case app_bluetooth.BluetoothConnectionStatus.disconnected:
        return 'Відключено';
      case app_bluetooth.BluetoothConnectionStatus.connecting:
        return 'Підключення...';
      case app_bluetooth.BluetoothConnectionStatus.disconnecting:
        return 'Відключення...';
      case app_bluetooth.BluetoothConnectionStatus.disabled:
        return 'Bluetooth вимкнено';
      case app_bluetooth.BluetoothConnectionStatus.unauthorized:
        return 'Немає дозволу';
    }
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}