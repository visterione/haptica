import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/gesture.dart';
import '../../domain/entities/recognition_result.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/usecases/get_recognition_history_usecase.dart';
import '../../domain/usecases/recognize_gesture_usecase.dart';

/// Стан розпізнавання
enum RecognitionState {
  /// Очікування даних
  idle,

  /// Розпізнавання
  recognizing,

  /// Розпізнано успішно
  recognized,

  /// Помилка розпізнавання
  error,
}

/// ViewModel для розпізнавання жестів
class RecognitionViewModel extends ChangeNotifier {
  /// Use case для розпізнавання жесту
  final RecognizeGestureUseCase _recognizeGestureUseCase;

  /// Use case для отримання історії розпізнавання
  final GetRecognitionHistoryUseCase _getRecognitionHistoryUseCase;

  /// Поточний стан розпізнавання
  RecognitionState _state = RecognitionState.idle;

  /// Останній розпізнаний результат
  RecognitionResult? _lastResult;

  /// Історія розпізнавання
  List<RecognitionResult> _history = [];

  /// Поточний розпізнаний текст
  String _recognizedText = '';

  /// Таймер для скидання стану
  Timer? _resetTimer;

  /// Помилка розпізнавання
  String? _error;

  /// Конструктор
  RecognitionViewModel(
      this._recognizeGestureUseCase,
      this._getRecognitionHistoryUseCase,
      ) {
    _loadHistory();
  }

  /// Завантаження історії розпізнавання
  Future<void> _loadHistory() async {
    final result = await _getRecognitionHistoryUseCase.execute(
      const GetRecognitionHistoryParams(limit: 20),
    );

    result.fold(
          (failure) {
        _error = failure.message;
        notifyListeners();
      },
          (history) {
        _history = history;
        notifyListeners();
      },
    );
  }

  /// Поточний стан розпізнавання
  RecognitionState get state => _state;

  /// Останній розпізнаний результат
  RecognitionResult? get lastResult => _lastResult;

  /// Історія розпізнавання
  List<RecognitionResult> get history => _history;

  /// Поточний розпізнаний текст
  String get recognizedText => _recognizedText;

  /// Помилка розпізнавання
  String? get error => _error;

  /// Оновлення розпізнаного тексту
  void updateRecognizedText(String newText) {
    _recognizedText = newText;
    notifyListeners();
  }

  /// Розпізнавання жесту за даними сенсорів
  Future<void> recognizeGesture(SensorData sensorData) async {
    // Скасовуємо попередній таймер, якщо він існує
    _resetTimer?.cancel();

    // Встановлюємо стан розпізнавання
    _state = RecognitionState.recognizing;
    notifyListeners();

    try {
      final result = await _recognizeGestureUseCase.execute(
        RecognizeGestureParams(sensorData: sensorData),
      );

      result.fold(
            (failure) {
          _state = RecognitionState.error;
          _error = failure.message;
          notifyListeners();

          // Автоматичне скидання стану через 2 секунди
          _resetTimer = Timer(const Duration(seconds: 2), () {
            _state = RecognitionState.idle;
            _error = null;
            notifyListeners();
          });
        },
            (recognitionResult) {
          _state = RecognitionState.recognized;
          _lastResult = recognitionResult;

          // Додаємо текст до розпізнаного тексту
          _appendText(recognitionResult.gesture.name);

          // Оновлюємо історію
          _loadHistory();

          notifyListeners();

          // Автоматичне скидання стану через 2 секунди
          _resetTimer = Timer(const Duration(seconds: 2), () {
            _state = RecognitionState.idle;
            notifyListeners();
          });
        },
      );
    } catch (e) {
      _state = RecognitionState.error;
      _error = e.toString();
      notifyListeners();

      // Автоматичне скидання стану через 2 секунди
      _resetTimer = Timer(const Duration(seconds: 2), () {
        _state = RecognitionState.idle;
        _error = null;
        notifyListeners();
      });
    }
  }

  /// Додавання тексту до розпізнаного тексту
  void _appendText(String text) {
    // Якщо текст - літера, просто додаємо її
    if (text.length == 1) {
      _recognizedText += text;
    }
    // Якщо це цифра або загальний жест, додаємо пробіл перед ним
    else {
      if (_recognizedText.isNotEmpty && !_recognizedText.endsWith(' ')) {
        _recognizedText += ' ';
      }
      _recognizedText += text;
    }
  }

  /// Очищення розпізнаного тексту
  void clearRecognizedText() {
    _recognizedText = '';
    notifyListeners();
  }

  /// Додавання пробілу до розпізнаного тексту
  void addSpace() {
    _recognizedText += ' ';
    notifyListeners();
  }

  /// Видалення останнього символу з розпізнаного тексту
  void backspace() {
    if (_recognizedText.isNotEmpty) {
      _recognizedText = _recognizedText.substring(0, _recognizedText.length - 1);
      notifyListeners();
    }
  }

  /// Отримання кольору стану розпізнавання
  int getStateColor() {
    switch (_state) {
      case RecognitionState.idle:
        return 0xFF808080; // Сірий
      case RecognitionState.recognizing:
        return 0xFF0066CC; // Синій
      case RecognitionState.recognized:
        return 0xFF00CC66; // Зелений
      case RecognitionState.error:
        return 0xFFCC0000; // Червоний
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }
}