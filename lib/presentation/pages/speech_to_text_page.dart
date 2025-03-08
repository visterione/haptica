import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import '../../core/constants/app_theme.dart';
import '../viewmodels/speech_to_text_viewmodel.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';

/// Сторінка для перетворення мовлення на текст
class SpeechToTextPage extends StatefulWidget {
  /// Шлях до сторінки
  static const String routeName = '/speech-to-text';

  /// Конструктор
  const SpeechToTextPage({Key? key}) : super(key: key);

  @override
  State<SpeechToTextPage> createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  /// Об'єкт розпізнавання мовлення
  final stt.SpeechToText _speech = stt.SpeechToText();

  /// Стан ініціалізації розпізнавання мовлення
  bool _speechInitialized = false;

  /// Стан розпізнавання мовлення
  bool _isListening = false;

  /// Розпізнаний текст
  String _recognizedText = '';

  /// Рівень достовірності розпізнавання
  double _confidence = 0.0;

  /// Контролер тексту
  final TextEditingController _textController = TextEditingController();

  /// Фокус-вузол для текстового поля
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Ініціалізація розпізнавання мовлення
  Future<void> _initSpeech() async {
    _speechInitialized = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );
    setState(() {});
  }

  /// Обробник зміни статусу розпізнавання мовлення
  void _onSpeechStatus(String status) {
    if (status == 'notListening') {
      setState(() {
        _isListening = false;
      });
    }
  }

  /// Обробник помилок розпізнавання мовлення
  void _onSpeechError(dynamic error) {
    setState(() {
      _isListening = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Помилка розпізнавання: $error'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  /// Обробник результатів розпізнавання мовлення
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
      if (result.finalResult) {
        _isListening = false;
        _confidence = result.confidence;

        // Додаємо текст до текстового поля
        _textController.text += ' ' + _recognizedText;
        _textController.text = _textController.text.trim();
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      }
    });
  }

  /// Запуск/зупинка розпізнавання мовлення
  void _toggleListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      if (_speechInitialized) {
        _recognizedText = '';
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: _onSpeechResult,
          localeId: 'uk_UA', // Українська мова
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Розпізнавання мовлення недоступне на цьому пристрої'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Очищення тексту
  void _clearText() {
    setState(() {
      _textController.clear();
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Розпізнавання мовлення',
      currentTab: AppTab.microphone,
      body: GestureDetector(
        onTap: () {
          // Зняття фокусу при натисканні поза полем введення
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            children: [
              // Картка з інструкцією
              Card(
                margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: AppTheme.accentColor),
                      SizedBox(width: AppTheme.paddingRegular),
                      Expanded(
                        child: Text(
                          'Натисніть кнопку мікрофона та говоріть. Ваше мовлення буде перетворено на текст.',
                          style: TextStyle(fontSize: AppTheme.fontSizeRegular),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Поле з текстом
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: Stack(
                      children: [
                        // Поле введення тексту
                        TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Тут з\'явиться розпізнаний текст...',
                            hintStyle: TextStyle(
                              color: AppTheme.textLightColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            color: AppTheme.textColor,
                          ),
                        ),

                        // Кнопки керування текстом (копіювання, очищення)
                        if (_textController.text.isNotEmpty)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Row(
                              children: [
                                // Кнопка копіювання тексту
                                IconButton(
                                  icon: const Icon(Icons.copy, color: AppTheme.accentColor),
                                  tooltip: 'Копіювати',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _textController.text));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Текст скопійовано в буфер обміну'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),

                                // Кнопка очищення
                                IconButton(
                                  icon: const Icon(Icons.clear, color: AppTheme.errorColor),
                                  tooltip: 'Очистити',
                                  onPressed: _clearText,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Секція з кнопками керування
              Container(
                margin: const EdgeInsets.only(top: AppTheme.paddingMedium),
                child: Column(
                  children: [
                    // Кнопка мікрофона
                    GestureDetector(
                      onTap: _toggleListening,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening ? AppTheme.errorColor : AppTheme.primaryColor,
                          boxShadow: AppTheme.mediumShadow,
                        ),
                        child: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    // Підказка
                    Padding(
                      padding: const EdgeInsets.only(top: AppTheme.paddingRegular),
                      child: Text(
                        _isListening ? 'Говоріть...' : 'Натисніть для початку',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeRegular,
                          color: _isListening ? AppTheme.errorColor : AppTheme.textLightColor,
                        ),
                      ),
                    ),

                    // Індикатор активності мікрофона
                    if (_isListening)
                      Container(
                        margin: const EdgeInsets.only(top: AppTheme.paddingRegular),
                        width: 200,
                        child: const LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),

                    // Рядок з кнопками керування
                    Container(
                      margin: const EdgeInsets.only(top: AppTheme.paddingLarge),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AppButton(
                            text: 'Очистити',
                            icon: Icons.delete_sweep,
                            type: AppButtonType.danger,
                            onPressed: _clearText,
                          ),
                          AppButton(
                            text: 'Копіювати',
                            icon: Icons.content_copy,
                            type: AppButtonType.secondary,
                            onPressed: _textController.text.isEmpty
                                ? null
                                : () {
                              Clipboard.setData(ClipboardData(text: _textController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Текст скопійовано в буфер обміну'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}