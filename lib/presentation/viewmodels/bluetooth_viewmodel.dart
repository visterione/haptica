import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/services/bluetooth_service.dart';

/// ViewModel для роботи з Bluetooth
class BluetoothViewModel extends ChangeNotifier {
  /// Сервіс Bluetooth
  final BluetoothManagerService _bluetoothService;

  /// Список доступних пристроїв
  List<BluetoothDevice> _devices = [];

  /// Поточний статус підключення
  BluetoothConnectionStatus _connectionStatus = BluetoothConnectionStatus.disconnected;

  /// Обраний пристрій
  BluetoothDevice? _selectedDevice;

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
  List<BluetoothDevice> get devices => _devices;

  /// Поточний статус підключення
  BluetoothConnectionStatus get connectionStatus => _connectionStatus;

  /// Обраний пристрій
  BluetoothDevice? get selectedDevice => _selectedDevice;

  /// Прапорець сканування
  bool get isScanning => _isScanning;

  /// Останні отримані дані сенсорів
  SensorData? get lastSensorData => _lastSensorData;

  /// Перевірка, чи підключено пристрій
  bool get isConnected => _connectionStatus == BluetoothConnectionStatus.connected;

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
  Future<bool> connectToDevice(BluetoothDevice device) async {
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
      case BluetoothConnectionStatus.connected:
        return 'Підключено';
      case BluetoothConnectionStatus.disconnected:
        return 'Відключено';
      case BluetoothConnectionStatus.connecting:
        return 'Підключення...';
      case BluetoothConnectionStatus.disconnecting:
        return 'Відключення...';
      case BluetoothConnectionStatus.disabled:
        return 'Bluetooth вимкнено';
      case BluetoothConnectionStatus.unauthorized:
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