import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../viewmodels/settings_viewmodel.dart';

/// Екран налаштувань
class SettingsPage extends StatefulWidget {
  /// Шлях до сторінки
  static const String routeName = '/settings';

  /// Конструктор
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// Поріг впевненості розпізнавання
  double _recognitionThreshold = 0.85;

  /// Автоматичне підключення Bluetooth
  bool _autoConnectBluetooth = true;

  /// Автоматичне перетворення тексту в мовлення
  bool _textToSpeechEnabled = false;

  /// Обрана мова
  String _selectedLanguage = 'uk';

  /// Обрана тема
  ThemeMode _selectedThemeMode = ThemeMode.light;

  /// Вібрація при розпізнаванні
  bool _hapticFeedbackEnabled = true;

  /// Показувати підказки
  bool _showHints = true;

  @override
  void initState() {
    super.initState();

    // Отримання налаштувань з ViewModel
    final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);

    if (settingsViewModel.settings != null) {
      _recognitionThreshold = settingsViewModel.settings!.recognitionThreshold;
      _autoConnectBluetooth = settingsViewModel.settings!.bluetoothAutoConnect;
      _textToSpeechEnabled = settingsViewModel.settings!.useTextToSpeech;
      _selectedLanguage = settingsViewModel.settings!.language;
      _hapticFeedbackEnabled = settingsViewModel.settings!.hapticFeedback;
      _showHints = settingsViewModel.settings!.showOnboarding;
    }

    _selectedThemeMode = settingsViewModel.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Налаштування',
      currentTab: AppTab.profile,
      showBottomNavigation: false,
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        children: [
          // Секція розпізнавання
          _buildSectionTitle('Розпізнавання жестів'),

          // Поріг впевненості розпізнавання
          _buildSliderSetting(
            title: 'Поріг впевненості',
            subtitle: 'Мінімальний рівень впевненості для розпізнавання жесту',
            value: _recognitionThreshold,
            min: 0.5,
            max: 0.95,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _recognitionThreshold = value;
              });
            },
            valueLabel: '${(_recognitionThreshold * 100).toInt()}%',
          ),

          const Divider(),

          // Секція Bluetooth
          _buildSectionTitle('Bluetooth'),

          // Автоматичне підключення
          _buildSwitchSetting(
            title: 'Автоматичне підключення',
            subtitle: 'Автоматично підключатися до останнього відомого пристрою',
            value: _autoConnectBluetooth,
            onChanged: (value) {
              setState(() {
                _autoConnectBluetooth = value;
              });
            },
          ),

          const Divider(),

          // Секція інтерфейсу
          _buildSectionTitle('Інтерфейс'),

          // Вибір теми
          ListTile(
            title: const Text('Тема додатку'),
            subtitle: const Text('Оберіть тему інтерфейсу'),
            leading: const Icon(Icons.brightness_4),
            trailing: DropdownButton<ThemeMode>(
              value: _selectedThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Світла'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Темна'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Системна'),
                ),
              ],
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedThemeMode = newValue;
                  });
                }
              },
              underline: Container(
                height: 2,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          // Список мов
          _buildDropdownSetting(
            title: 'Мова інтерфейсу',
            subtitle: 'Оберіть мову інтерфейсу додатку',
            value: _selectedLanguage,
            items: const {
              'uk': 'Українська',
              'en': 'English',
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
              }
            },
          ),

          // Перетворення тексту в мовлення
          _buildSwitchSetting(
            title: 'Текст в мовлення',
            subtitle: 'Автоматично озвучувати розпізнаний текст',
            value: _textToSpeechEnabled,
            onChanged: (value) {
              setState(() {
                _textToSpeechEnabled = value;
              });
            },
          ),

          // Вібрація при розпізнаванні
          _buildSwitchSetting(
            title: 'Тактильний відгук',
            subtitle: 'Вібрація при розпізнаванні жестів',
            value: _hapticFeedbackEnabled,
            onChanged: (value) {
              setState(() {
                _hapticFeedbackEnabled = value;
              });
            },
          ),

          // Показувати підказки
          _buildSwitchSetting(
            title: 'Підказки',
            subtitle: 'Показувати підказки та навчальні матеріали',
            value: _showHints,
            onChanged: (value) {
              setState(() {
                _showHints = value;
              });
            },
          ),

          const Divider(),

          // Секція про додаток
          _buildSectionTitle('Про додаток'),

          ListTile(
            title: const Text('Версія'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              // Показати інформацію про версію
              _showAboutDialog();
            },
          ),

          const SizedBox(height: AppTheme.paddingLarge),

          // Кнопка збереження
          AppButton(
            text: 'Зберегти налаштування',
            type: AppButtonType.primary,
            onPressed: _saveSettings,
          ),
        ],
      ),
    );
  }

  /// Збереження налаштувань
  Future<void> _saveSettings() async {
    final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);

    // Збереження теми
    await settingsViewModel.setThemeMode(_selectedThemeMode);

    // Збереження інших налаштувань, якщо модель доступна
    if (settingsViewModel.settings != null) {
      final newSettings = settingsViewModel.settings!.copyWith(
        recognitionThreshold: _recognitionThreshold,
        bluetoothAutoConnect: _autoConnectBluetooth,
        useTextToSpeech: _textToSpeechEnabled,
        language: _selectedLanguage,
        hapticFeedback: _hapticFeedbackEnabled,
        showOnboarding: _showHints,
        updatedAt: DateTime.now(),
      );

      await settingsViewModel.saveSettings(newSettings);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Налаштування збережено'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    Navigator.of(context).pop();
  }

  /// Показує діалог про додаток
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Про додаток'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Перекладач жестів Haptica'),
            SizedBox(height: AppTheme.paddingRegular),
            Text('Версія: 1.0.0'),
            SizedBox(height: AppTheme.paddingRegular),
            Text('Інтелектуальна система перетворення жестової мови на базі смарт-рукавички'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрити'),
          ),
        ],
      ),
    );
  }

  /// Побудова заголовку секції
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppTheme.paddingMedium,
        bottom: AppTheme.paddingRegular,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppTheme.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryDarkColor,
        ),
      ),
    );
  }

  /// Побудова налаштування слайдеру
  Widget _buildSliderSetting({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          leading: const Icon(Icons.tune),
          trailing: Text(
            valueLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          activeColor: AppTheme.primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Побудова налаштування перемикача
  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: const Icon(Icons.settings),
      trailing: Switch(
        value: value,
        activeColor: AppTheme.primaryColor,
        onChanged: onChanged,
      ),
    );
  }

  /// Побудова налаштування випадаючого списку
  Widget _buildDropdownSetting<T>({
    required String title,
    required String subtitle,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: const Icon(Icons.language),
      trailing: DropdownButton<T>(
        value: value,
        items: items.entries.map((entry) {
          return DropdownMenuItem<T>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: onChanged,
        underline: Container(
          height: 2,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}