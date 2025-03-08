import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/datasources/database_helper.dart';
import '../../data/repositories/gesture_repository_impl.dart';
import '../../data/repositories/recognition_result_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_settings_repository_impl.dart';
import '../../domain/repositories/gesture_repository.dart';
import '../../domain/repositories/recognition_result_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../../domain/services/bluetooth_service.dart';
import '../../domain/services/ml_service.dart';
import '../../domain/usecases/get_recognition_history_usecase.dart';
import '../../domain/usecases/recognize_gesture_usecase.dart';
import '../../presentation/viewmodels/bluetooth_viewmodel.dart';
import '../../presentation/viewmodels/recognition_viewmodel.dart';
import '../../presentation/viewmodels/settings_viewmodel.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';

/// Глобальний ServiceLocator
final GetIt sl = GetIt.instance;

/// Ініціалізація dependency injection
Future<void> init() async {
  // ViewModels
  sl.registerFactory(() => BluetoothViewModel(sl()));
  sl.registerFactory(() => RecognitionViewModel(sl(), sl()));
  sl.registerFactory(() => SettingsViewModel(sl()));
  sl.registerFactory(() => AuthViewModel(sl()));

  // Use cases
  sl.registerLazySingleton(() => RecognizeGestureUseCase(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GetRecognitionHistoryUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<GestureRepository>(() => GestureRepositoryImpl(sl()));
  sl.registerLazySingleton<RecognitionResultRepository>(
          () => RecognitionResultRepositoryImpl(sl(), sl())
  );
  sl.registerLazySingleton<UserSettingsRepository>(() => UserSettingsRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    firebaseAuth: sl(),
    googleSignIn: sl(),
  ));

  // Services
  sl.registerLazySingleton<BluetoothManagerService>(() => BluetoothManagerServiceImpl());
  sl.registerLazySingleton<MLService>(() => MLServiceImpl());

  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Data sources
  sl.registerLazySingleton(() => DatabaseHelper.instance);

  // Попередня ініціалізація залежностей, які цього потребують
  final mlService = sl<MLService>();
  await mlService.initialize();
}