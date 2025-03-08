import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

/// ViewModel для функціоналу перетворення мовлення на текст
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

  /// Конструктор
  SpeechToTextViewModel() {
    _initSpeech();
  }

  /// Ініціалізація розпізнавання мовлення
  Future<void> _initSpeech() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (error) {
          _error = error.errorMsg;
          _isListening = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isInitialized = false;
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
    } else {
      if (_isInitialized) {
        _recognizedText = '';
        _isListening = true;
        notifyListeners();

        await _speech.listen(
          onResult: _onSpeechResult,
          localeId: 'uk_UA', // Українська мова
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        _error = "Розпізнавання мовлення не ініціалізовано";
      }
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