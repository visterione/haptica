import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptica/presentation/viewmodels/speech_to_text_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/pages/home_page.dart';
import 'presentation/viewmodels/bluetooth_viewmodel.dart';
import 'presentation/viewmodels/recognition_viewmodel.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/navigation/app_router.dart';
import 'firebase_options.dart';

void main() async {
  // Ініціалізація Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Ініціалізація Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        ChangeNotifierProvider(
          create: (_) => di.sl<SettingsViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<SpeechToTextViewModel>(),  // Додано новий провайдер
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'Перекладач жестів',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsViewModel.themeMode,
            initialRoute: AppRouter.home,
            routes: AppRouter.getRoutes(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}