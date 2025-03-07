import 'dart:async';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import '../entities/sensor_data.dart';

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

/// Клас, що імітує Bluetooth-пристрій
class BluetoothDevice {
  /// Адреса пристрою
  final String address;

  /// Назва пристрою
  final String? name;

  /// Конструктор
  BluetoothDevice({required this.address, this.name});
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

/// Симуляція сервісу Bluetooth
class BluetoothManagerServiceImpl implements BluetoothManagerService {
  /// Фіктивні пристрої
  final List<BluetoothDevice> _mockDevices = [
    BluetoothDevice(address: '00:11:22:33:44:55', name: 'Смарт-рукавичка'),
    BluetoothDevice(address: 'AA:BB:CC:DD:EE:FF', name: 'Перекладач жестів'),
    BluetoothDevice(address: '11:22:33:44:55:66', name: 'Sign Language Translator'),
    BluetoothDevice(address: 'FF:EE:DD:CC:BB:AA', name: 'Жестова рукавичка'),
  ];

  /// Підключений пристрій
  BluetoothDevice? _connectedDevice;

  /// Контролер для потоку статусу з'єднання
  final StreamController<BluetoothConnectionStatus> _statusController =
  StreamController<BluetoothConnectionStatus>.broadcast();

  /// Контролер для потоку сенсорних даних
  final StreamController<SensorData> _dataController =
  StreamController<SensorData>.broadcast();

  /// Поточний статус з'єднання
  BluetoothConnectionStatus _status = BluetoothConnectionStatus.disconnected;

  /// Таймер для генерації даних
  Timer? _dataGenerationTimer;

  /// Генератор випадкових чисел
  final Random _random = Random();

  /// Конструктор
  BluetoothManagerServiceImpl() {
    // Ініціалізуємо з відключеним станом
    _updateStatus(BluetoothConnectionStatus.disconnected);
  }

  /// Оновлення статусу з'єднання
  void _updateStatus(BluetoothConnectionStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  @override
  BluetoothConnectionStatus get status => _status;

  @override
  Stream<BluetoothConnectionStatus> get statusStream => _statusController.stream;

  @override
  Stream<SensorData> get dataStream => _dataController.stream;

  @override
  Future<bool> requestPermissions() async {
    // Симуляція запиту дозволів
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<List<BluetoothDevice>> scanForDevices() async {
    // Симуляція процесу сканування
    await Future.delayed(const Duration(seconds: 2));
    return _mockDevices;
  }

  @override
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_status == BluetoothConnectionStatus.connecting) {
      return false;
    }

    _updateStatus(BluetoothConnectionStatus.connecting);

    // Симуляція процесу підключення
    await Future.delayed(const Duration(seconds: 1));

    _connectedDevice = device;
    _updateStatus(BluetoothConnectionStatus.connected);

    // Запуск генерації даних
    _startDataGeneration();

    return true;
  }

  @override
  Future<bool> disconnect() async {
    if (_status == BluetoothConnectionStatus.disconnected) {
      return true;
    }

    _updateStatus(BluetoothConnectionStatus.disconnecting);

    // Зупинка генерації даних
    _stopDataGeneration();

    // Симуляція процесу відключення
    await Future.delayed(const Duration(milliseconds: 500));

    _connectedDevice = null;
    _updateStatus(BluetoothConnectionStatus.disconnected);

    return true;
  }

  @override
  Future<bool> isBluetoothAvailable() async {
    // Симуляція перевірки доступності Bluetooth
    return true;
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    // Симуляція перевірки увімкнення Bluetooth
    return true;
  }

  @override
  Future<bool> enableBluetooth() async {
    // Симуляція увімкнення Bluetooth
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// Запуск генерації даних
  void _startDataGeneration() {
    // Зупиняємо попередній таймер, якщо він існує
    _stopDataGeneration();

    // Запускаємо новий таймер для генерації даних кожні 500 мс
    _dataGenerationTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      // Генеруємо випадкові дані сенсорів
      final sensorData = _generateRandomSensorData();

      // Відправляємо дані
      _dataController.add(sensorData);
    });
  }

  /// Зупинка генерації даних
  void _stopDataGeneration() {
    _dataGenerationTimer?.cancel();
    _dataGenerationTimer = null;
  }

  /// Генерація випадкових даних сенсорів
  SensorData _generateRandomSensorData() {
    // Генеруємо випадкові значення акселерометра (-1.0 до 1.0)
    final accelerometerData = AccelerometerData(
      x: (_random.nextDouble() * 2.0) - 1.0,
      y: (_random.nextDouble() * 2.0) - 1.0,
      z: (_random.nextDouble() * 2.0) - 1.0,
    );

    // Генеруємо випадкові значення гіроскопа (-2.0 до 2.0)
    final gyroscopeData = GyroscopeData(
      x: (_random.nextDouble() * 4.0) - 2.0,
      y: (_random.nextDouble() * 4.0) - 2.0,
      z: (_random.nextDouble() * 4.0) - 2.0,
    );

    // Генеруємо випадкові значення згину пальців (0.0 до 1.0)
    // Припускаємо, що у нас 5 пальців
    final flexValues = List<double>.generate(
      5,
          (_) => _random.nextDouble(),
    );

    final flexSensorData = FlexSensorData(values: flexValues);

    // Створюємо повний набір даних з часовою міткою
    return SensorData(
      accelerometer: accelerometerData,
      gyroscope: gyroscopeData,
      flexSensors: flexSensorData,
      timestamp: DateTime.now(),
    );
  }

  /// Звільнення ресурсів
  void dispose() {
    _stopDataGeneration();
    _statusController.close();
    _dataController.close();
  }
}