// lib/presentation/pages/help_page.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../widgets/app_scaffold.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Допомога',
      currentTab: AppTab.help,
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Як користуватися додатком',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppTheme.paddingRegular),
                  Text(
                    '1. Підключіть смарт-рукавичку через Bluetooth.\n'
                        '2. Використовуйте жести для перекладу на текст.\n'
                        '3. Відредагуйте текст за необхідності.\n'
                        '4. Збережіть або скопіюйте переклад.',
                    style: TextStyle(fontSize: AppTheme.fontSizeRegular),
                  ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Підключення пристрою',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppTheme.paddingRegular),
                  Text(
                    '1. Увімкніть Bluetooth на вашому телефоні.\n'
                        '2. Натисніть на іконку Bluetooth у верхньому куті додатку.\n'
                        '3. Виберіть вашу смарт-рукавичку зі списку пристроїв.\n'
                        '4. Слідуйте інструкціям на екрані для завершення підключення.',
                    style: TextStyle(fontSize: AppTheme.fontSizeRegular),
                  ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Часті запитання',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppTheme.paddingRegular),
                  ExpansionTile(
                    title: Text('Як змінити налаштування додатку?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppTheme.paddingRegular),
                        child: Text(
                          'Перейдіть до розділу "Профіль" і натисніть на пункт "Налаштування". '
                              'Там ви зможете змінити тему, мову інтерфейсу та інші параметри додатку.',
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('Що робити, якщо пристрій не підключається?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppTheme.paddingRegular),
                        child: Text(
                          '1. Переконайтеся, що Bluetooth увімкнено на вашому пристрої.\n'
                              '2. Перевірте, чи заряджена смарт-рукавичка.\n'
                              '3. Спробуйте перезавантажити смарт-рукавичку.\n'
                              '4. Якщо проблема не зникає, спробуйте перезавантажити телефон.',
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('Як додати новий жест?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppTheme.paddingRegular),
                        child: Text(
                          'На даний момент додавання користувацьких жестів не підтримується. '
                              'Ця функція буде доступна в наступних версіях додатку.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}