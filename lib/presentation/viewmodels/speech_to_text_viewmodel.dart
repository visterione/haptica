import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextViewModel extends ChangeNotifier {
  /// Об'єкт розпізнавання мовлення
  final stt.SpeechToText _speech = stt.SpeechToText();

  /// Стан ініціалізації
  bool _isInitialized = false;

  /// Стан прослуховування
  bool _isListening = false;

  /// Розпізнаний текст
  String _recognizedText = '';

  /// Повний текст (історія)
  String _fullText = '';

  /// Рівень достовірності
  double _confidence = 0.0;

  /// Помилка
  String? _error;

  /// Стан завантаження
  bool _isLoading = false;

  /// Перевірка на запит дозволу
  bool _permissionRequested = false;

  /// Конструктор
  SpeechToTextViewModel() {
    // Вже не викликаємо _initSpeech() в конструкторі
  }

  /// Ініціалізація розпізнавання мовлення з перевіркою дозволів
  Future<bool> checkPermissionAndInitialize() async {
    if (_isInitialized) return true;
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Перевіряємо, чи вже запитували дозвіл
      if (!_permissionRequested) {
        _permissionRequested = true;

        // Перевіряємо статус дозволу
        bool micPermissionGranted = await Permission.microphone.isGranted;
        if (!micPermissionGranted) {
          final status = await Permission.microphone.request();
          if (status != PermissionStatus.granted) {
            _error = "Дозвіл на використання мікрофона не надано";
            _isInitialized = false;
            _isLoading = false;
            notifyListeners();
            return false;
          }
        }
      }

      // Ініціалізуємо розпізнавання мовлення
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('Speech error: $error');
          _error = error.errorMsg;
          _isListening = false;
          notifyListeners();
        },
        debugLogging: true,
      );

      debugPrint('Speech initialized: $_isInitialized');
      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      _error = e.toString();
      _isInitialized = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Стан ініціалізації
  bool get isInitialized => _isInitialized;

  /// Стан прослуховування
  bool get isListening => _isListening;

  /// Розпізнаний текст
  String get recognizedText => _recognizedText;

  /// Повний текст (історія)
  String get fullText => _fullText;

  /// Рівень достовірності
  double get confidence => _confidence;

  /// Помилка
  String? get error => _error;

  /// Стан завантаження
  bool get isLoading => _isLoading;

  /// Запуск/зупинка розпізнавання мовлення
  Future<void> toggleListening() async {
    _error = null;

    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
      return;
    }

    if (!_isInitialized) {
      bool initialized = await checkPermissionAndInitialize();
      if (!initialized) {
        _error = "Не вдалося ініціалізувати розпізнавання мовлення";
        notifyListeners();
        return;
      }
    }

    try {
      _recognizedText = '';

      if (_isInitialized) {
        _isListening = true;
        notifyListeners();

        await _speech.listen(
          onResult: _onSpeechResult,
          localeId: 'uk_UA', // Українська мова
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        _error = "Розпізнавання мовлення недоступне на цьому пристрої";
      }
    } catch (e) {
      debugPrint('Error during speech recognition: $e');
      _error = e.toString();
      _isListening = false;
    }
    notifyListeners();
  }

  /// Обробник результатів розпізнавання мовлення
  void _onSpeechResult(SpeechRecognitionResult result) {
    _recognizedText = result.recognizedWords;

    if (result.finalResult) {
      _isListening = false;
      _confidence = result.confidence;

      // Додаємо результат до повного тексту
      if (_fullText.isNotEmpty && !_fullText.endsWith(' ')) {
        _fullText += ' ';
      }
      _fullText += _recognizedText;
    }

    notifyListeners();
  }

  /// Очищення тексту
  void clearText() {
    _fullText = '';
    notifyListeners();
  }

  /// Додавання тексту
  void addText(String text) {
    if (_fullText.isNotEmpty && !_fullText.endsWith(' ')) {
      _fullText += ' ';
    }
    _fullText += text;
    notifyListeners();
  }

  /// Видалення останнього символу
  void backspace() {
    if (_fullText.isNotEmpty) {
      _fullText = _fullText.substring(0, _fullText.length - 1);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}