import 'package:get_it/get_it.dart';

import '../../data/datasources/database_helper.dart';
import '../../data/repositories/gesture_repository_impl.dart';
import '../../data/repositories/recognition_result_repository_impl.dart';
import '../../domain/repositories/gesture_repository.dart';
import '../../domain/repositories/recognition_result_repository.dart';
import '../../domain/services/bluetooth_service.dart';
import '../../domain/services/ml_service.dart';
import '../../domain/usecases/get_recognition_history_usecase.dart';
import '../../domain/usecases/recognize_gesture_usecase.dart';
import '../../presentation/viewmodels/bluetooth_viewmodel.dart';
import '../../presentation/viewmodels/recognition_viewmodel.dart';

/// Глобальний ServiceLocator
final GetIt sl = GetIt.instance;

/// Ініціалізація dependency injection
Future<void> init() async {
  // ViewModels
  sl.registerFactory(() => BluetoothViewModel(sl()));
  sl.registerFactory(() => RecognitionViewModel(sl(), sl()));

  // Use cases
  sl.registerLazySingleton(() => RecognizeGestureUseCase(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GetRecognitionHistoryUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<GestureRepository>(() => GestureRepositoryImpl(sl()));
  sl.registerLazySingleton<RecognitionResultRepository>(
          () => RecognitionResultRepositoryImpl(sl(), sl())
  );

  // Services
  sl.registerLazySingleton<BluetoothManagerService>(() => BluetoothManagerServiceImpl());
  sl.registerLazySingleton<MLService>(() => MLServiceImpl());

  // Data sources
  sl.registerLazySingleton(() => DatabaseHelper.instance);

  // Зовнішні залежності

  // Попередня ініціалізація залежностей, які цього потребують
  final mlService = sl<MLService>();
  await mlService.initialize();
}