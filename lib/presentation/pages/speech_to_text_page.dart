import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  /// Контролер тексту
  final TextEditingController _textController = TextEditingController();

  /// Фокус-вузол для текстового поля
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Ініціалізуємо ViewModel після монтування віджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SpeechToTextViewModel>(context, listen: false);
      viewModel.checkPermissionAndInitialize();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechToTextViewModel>(
      builder: (context, viewModel, child) {
        // При зміні fullText оновлюємо текстовий контролер
        if (viewModel.fullText != _textController.text) {
          _textController.text = viewModel.fullText;
          // Встановлюємо курсор в кінець тексту
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        }

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
                              onChanged: (text) {
                                // Оновлюємо текст у viewModel, якщо користувач редагує його вручну
                                if (text != viewModel.fullText) {
                                  // Можна додати логіку оновлення тексту у viewModel
                                }
                              },
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
                                      onPressed: () {
                                        viewModel.clearText();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Відображення помилки, якщо вона є
                  if (viewModel.error != null)
                    Container(
                      margin: const EdgeInsets.only(top: AppTheme.paddingMedium),
                      padding: const EdgeInsets.all(AppTheme.paddingRegular),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.errorColor),
                          const SizedBox(width: AppTheme.paddingRegular),
                          Expanded(
                            child: Text(
                              viewModel.error!,
                              style: const TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Секція з кнопками керування
                  Container(
                    margin: const EdgeInsets.only(top: AppTheme.paddingMedium),
                    child: Column(
                      children: [
                        // Кнопка мікрофона
                        GestureDetector(
                          onTap: () {
                            viewModel.toggleListening();
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: viewModel.isListening ? AppTheme.errorColor : AppTheme.primaryColor,
                              boxShadow: AppTheme.mediumShadow,
                            ),
                            child: Icon(
                              viewModel.isListening ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),

                        // Підказка
                        Padding(
                          padding: const EdgeInsets.only(top: AppTheme.paddingRegular),
                          child: Text(
                            viewModel.isListening ? 'Говоріть...' : 'Натисніть для початку',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeRegular,
                              color: viewModel.isListening ? AppTheme.errorColor : AppTheme.textLightColor,
                            ),
                          ),
                        ),

                        // Індикатор активності мікрофона
                        if (viewModel.isListening)
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
                                onPressed: viewModel.isLoading ? null : viewModel.clearText,
                              ),
                              AppButton(
                                text: 'Копіювати',
                                icon: Icons.content_copy,
                                type: AppButtonType.secondary,
                                onPressed: viewModel.isLoading || _textController.text.isEmpty
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
      },
    );
  }
}