import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/pages/home_page.dart';
import 'presentation/viewmodels/bluetooth_viewmodel.dart';
import 'presentation/viewmodels/recognition_viewmodel.dart';

void main() async {
  // Ініціалізація Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Встановлення орієнтації екрану
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Ініціалізація залежностей
  await di.init();

  // Запуск додатку
  runApp(const MyApp());
}

/// Головний клас додатку
class MyApp extends StatelessWidget {
  /// Конструктор
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<BluetoothViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<RecognitionViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'Перекладач жестів',
        theme: AppTheme.lightTheme,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}