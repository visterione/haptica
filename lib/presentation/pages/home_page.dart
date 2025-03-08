import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_theme.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/services/bluetooth_service.dart';
import '../viewmodels/bluetooth_viewmodel.dart';
import '../viewmodels/recognition_viewmodel.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import 'bluetooth_page.dart';

/// Головний екран додатку
class HomePage extends StatefulWidget {
  /// Шлях до сторінки
  static const String routeName = '/home';

  /// Конструктор
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  /// Контролер для анімації стану розпізнавання
  late AnimationController _animationController;

  /// Фокус-вузол для текстового поля
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Ініціалізація контролера анімації
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Отримання viewmodel
    final bluetoothViewModel = Provider.of<BluetoothViewModel>(context, listen: false);
    final recognitionViewModel = Provider.of<RecognitionViewModel>(context, listen: false);

    // Підписка на отримання нових даних з сенсорів
    bluetoothViewModel.onNewSensorData = (SensorData data) {
      recognitionViewModel.recognizeGesture(data);
    };

    // Перевірка дозволів Bluetooth
    Future.delayed(Duration.zero, () async {
      await bluetoothViewModel.checkPermissions();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecognitionViewModel>(
      builder: (context, recognitionViewModel, child) {
        final hasText = recognitionViewModel.recognizedText.isNotEmpty;

        return AppScaffold(
          title: 'Haptica',
          currentTab: AppTab.gestures,
          body: GestureDetector(
            onTap: () {
              // Зняття фокусу при натисканні поза полем введення
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              child: Column(
                children: [
                  // Верхня секція: статус Bluetooth
                  _buildBluetoothStatusSection(),

                  // Секція розпізнаного тексту
                  _buildRecognizedTextSection(),

                  // Індикатор процесу розпізнавання
                  _buildRecognitionIndicator(),

                  // Кнопки управління
                  _buildControlButtons(),

                  // Додаємо Spacer, щоб заповнити пустий простір
                  const Spacer(),
                ],
              ),
            ),
          ),
          // Додаємо плаваючу кнопку для копіювання, якщо є текст
          floatingActionButton: hasText ? FloatingActionButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: recognitionViewModel.recognizedText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Текст скопійовано в буфер обміну'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: AppTheme.accentColor,
            child: const Icon(Icons.content_copy),
            tooltip: 'Копіювати текст',
          ) : null,
        );
      },
    );
  }

  /// Побудова секції статусу Bluetooth
  Widget _buildBluetoothStatusSection() {
    return Consumer<BluetoothViewModel>(
      builder: (context, bluetoothViewModel, child) {
        final status = bluetoothViewModel.connectionStatus;
        final statusName = bluetoothViewModel.getStatusName();
        final deviceName = bluetoothViewModel.selectedDevice?.name ?? 'Пристрій не обрано';

        Color statusColor;
        IconData statusIcon;

        switch (status) {
          case BluetoothConnectionStatus.connected:
            statusColor = AppTheme.successColor;
            statusIcon = Icons.bluetooth_connected;
            break;
          case BluetoothConnectionStatus.connecting:
            statusColor = AppTheme.warningColor;
            statusIcon = Icons.bluetooth_searching;
            break;
          case BluetoothConnectionStatus.disconnecting:
            statusColor = AppTheme.warningColor;
            statusIcon = Icons.bluetooth_disabled;
            break;
          case BluetoothConnectionStatus.disabled:
            statusColor = AppTheme.errorColor;
            statusIcon = Icons.bluetooth_disabled;
            break;
          case BluetoothConnectionStatus.unauthorized:
            statusColor = AppTheme.errorColor;
            statusIcon = Icons.block;
            break;
          case BluetoothConnectionStatus.disconnected:
          default:
            statusColor = AppTheme.textLightColor;
            statusIcon = Icons.bluetooth;
            break;
        }

        return Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          color: statusColor.withOpacity(0.1),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor),
              const SizedBox(width: AppTheme.paddingRegular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    if (status == BluetoothConnectionStatus.connected)
                      Text(
                        deviceName,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeSmall,
                          color: AppTheme.textLightColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (status == BluetoothConnectionStatus.connected)
                TextButton(
                  onPressed: () async {
                    await bluetoothViewModel.disconnect();
                  },
                  child: const Text('Відключити'),
                )
              else
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BluetoothPage()),
                    );
                  },
                  child: const Text('Підключити'),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Побудова секції розпізнаного тексту
  Widget _buildRecognizedTextSection() {
    return Consumer<RecognitionViewModel>(
      builder: (context, recognitionViewModel, child) {
        final text = recognitionViewModel.recognizedText;

        return Expanded(
          flex: 5, // Збільшуємо flex з 3 до 5, щоб секція займала більше місця
          child: Container(
            margin: const EdgeInsets.all(AppTheme.paddingMedium),
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: AppTheme.lightShadow,
            ),
            child: Stack(
              children: [
                // Текстове поле
                TextField(
                  readOnly: true,
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
                  controller: TextEditingController(text: text),
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeLarge,
                    color: AppTheme.textColor,
                  ),
                ),

                // Кнопки копіювання тексту та очищення
                if (text.isNotEmpty)
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
                            Clipboard.setData(ClipboardData(text: text));
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
                            recognitionViewModel.clearRecognizedText();
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Побудова індикатора процесу розпізнавання
  Widget _buildRecognitionIndicator() {
    return Consumer<RecognitionViewModel>(
      builder: (context, recognitionViewModel, child) {
        final state = recognitionViewModel.state;

        // Визначення кольору та анімації в залежності від стану
        Color indicatorColor;
        Widget indicatorWidget;

        switch (state) {
          case RecognitionState.idle:
            indicatorColor = Color(0xFF808080); // Сірий
            indicatorWidget = const Icon(
              Icons.mic_none,
              size: 50,
              color: Color(0xFF808080),
            );
            _animationController.reset();
            break;
          case RecognitionState.recognizing:
            indicatorColor = Color(0xFF0066CC); // Синій
            indicatorWidget = Lottie.asset(
              'assets/animations/recognizing.json',
              width: 80,
              height: 80,
              animate: true,
            );
            _animationController.repeat();
            break;
          case RecognitionState.recognized:
            indicatorColor = Color(0xFF00CC66); // Зелений
            indicatorWidget = const Icon(
              Icons.check_circle,
              size: 50,
              color: Color(0xFF00CC66),
            );
            _animationController.forward();
            break;
          case RecognitionState.error:
            indicatorColor = Color(0xFFCC0000); // Червоний
            indicatorWidget = const Icon(
              Icons.error,
              size: 50,
              color: Color(0xFFCC0000),
            );
            _animationController.reset();
            break;
        }

        return Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            children: [
              // Індикатор
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indicatorColor.withOpacity(0.1),
                ),
                child: Center(
                  child: indicatorWidget,
                ),
              ),

              const SizedBox(height: AppTheme.paddingRegular),

              // Статус
              Text(
                _getStatusText(state),
                style: TextStyle(
                  fontSize: AppTheme.fontSizeRegular,
                  fontWeight: FontWeight.bold,
                  color: indicatorColor,
                ),
              ),

              // Помилка, якщо є
              if (state == RecognitionState.error && recognitionViewModel.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.paddingRegular),
                  child: Text(
                    recognitionViewModel.error!,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Отримання тексту статусу
  String _getStatusText(RecognitionState state) {
    switch (state) {
      case RecognitionState.idle:
        return 'Готовий до розпізнавання';
      case RecognitionState.recognizing:
        return 'Розпізнавання...';
      case RecognitionState.recognized:
        return 'Жест розпізнано';
      case RecognitionState.error:
        return 'Помилка розпізнавання';
    }
  }

  /// Побудова кнопок управління
  Widget _buildControlButtons() {
    return Consumer<RecognitionViewModel>(
      builder: (context, recognitionViewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingLarge, // Збільшуємо відступ
          ),
          child: Column(
            children: [
              // Рядок з кнопками для основних дій
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Кнопка пробілу
                  AppButton(
                    text: 'Пробіл',
                    icon: Icons.space_bar,
                    type: AppButtonType.secondary,
                    onPressed: () {
                      recognitionViewModel.addSpace();
                    },
                  ),

                  // Кнопка видалення
                  AppButton(
                    text: 'Видалити',
                    icon: Icons.backspace,
                    type: AppButtonType.secondary,
                    onPressed: () {
                      recognitionViewModel.backspace();
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.paddingMedium),

              // Кнопка очищення внизу і ширша
              AppButton(
                text: 'Очистити все',
                icon: Icons.clear_all,
                type: AppButtonType.danger,
                size: const Size(200, 48), // Збільшуємо розмір кнопки
                onPressed: () {
                  recognitionViewModel.clearRecognizedText();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}