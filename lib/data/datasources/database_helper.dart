import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Допоміжний клас для роботи з базою даних SQLite
class DatabaseHelper {
  /// Ім'я файлу бази даних
  static const String _databaseName = "gesture_translator.db";

  /// Версія бази даних
  static const int _databaseVersion = 1;

  /// Назва таблиці жестів
  static const String tableGestures = 'gestures';

  /// Назва таблиці результатів розпізнавання
  static const String tableRecognitionResults = 'recognition_results';

  /// Назва таблиці налаштувань користувача
  static const String tableUserSettings = 'user_settings';

  /// Назва таблиці історії сесій
  static const String tableSessionHistory = 'session_history';

  /// Назва таблиці статистики розпізнавання
  static const String tableRecognitionStatistics = 'recognition_statistics';

  /// Одиночний екземпляр класу (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._internal();

  /// Екземпляр бази даних
  Database? _database;

  /// Приватний конструктор для забезпечення патерну Singleton
  DatabaseHelper._internal();

  /// Отримання екземпляру бази даних з лінивою ініціалізацією
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  /// Ініціалізація бази даних
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Створення таблиць бази даних
  Future<void> _onCreate(Database db, int version) async {
    // Таблиця жестів
    await db.execute('''
      CREATE TABLE $tableGestures (
        gesture_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Таблиця результатів розпізнавання
    await db.execute('''
      CREATE TABLE $tableRecognitionResults (
        result_id INTEGER PRIMARY KEY AUTOINCREMENT,
        gesture_id INTEGER NOT NULL,
        confidence REAL NOT NULL,
        raw_data TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (gesture_id) REFERENCES $tableGestures (gesture_id) ON DELETE CASCADE
      )
    ''');

    // Таблиця налаштувань користувача
    await db.execute('''
      CREATE TABLE $tableUserSettings (
        setting_id INTEGER PRIMARY KEY AUTOINCREMENT,
        setting_name TEXT NOT NULL UNIQUE,
        setting_value TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    // Таблиця історії сесій
    await db.execute('''
      CREATE TABLE $tableSessionHistory (
        session_id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        total_gestures INTEGER NOT NULL DEFAULT 0,
        success_rate REAL
      )
    ''');

    // Таблиця статистики розпізнавання
    await db.execute('''
      CREATE TABLE $tableRecognitionStatistics (
        stat_id INTEGER PRIMARY KEY AUTOINCREMENT,
        gesture_id INTEGER NOT NULL,
        total_attempts INTEGER NOT NULL DEFAULT 0,
        successful_attempts INTEGER NOT NULL DEFAULT 0,
        average_confidence REAL,
        last_updated TEXT NOT NULL,
        FOREIGN KEY (gesture_id) REFERENCES $tableGestures (gesture_id) ON DELETE CASCADE
      )
    ''');

    // Створення індексів
    await db.execute('CREATE INDEX idx_recognition_results_gesture_id ON $tableRecognitionResults (gesture_id)');
    await db.execute('CREATE INDEX idx_recognition_statistics_gesture_id ON $tableRecognitionStatistics (gesture_id)');

    // Додавання початкових даних
    await _insertInitialData(db);
  }

  /// Оновлення бази даних при зміні версії
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Логіка оновлення бази даних між версіями
    if (oldVersion < 2) {
      // Приклад оновлення для версії 2
    }
  }

  /// Вставка початкових даних
  Future<void> _insertInitialData(Database db) async {
    // Додавання базових жестів української дактильної абетки
    final now = DateTime.now().toIso8601String();

    // Літери
    final letterGestures = [
      {'name': 'А', 'category': 'letter', 'description': 'Літера А української дактильної абетки', 'created_at': now},
      {'name': 'Б', 'category': 'letter', 'description': 'Літера Б української дактильної абетки', 'created_at': now},
      {'name': 'В', 'category': 'letter', 'description': 'Літера В української дактильної абетки', 'created_at': now},
      {'name': 'Г', 'category': 'letter', 'description': 'Літера Г української дактильної абетки', 'created_at': now},
      {'name': 'Ґ', 'category': 'letter', 'description': 'Літера Ґ української дактильної абетки', 'created_at': now},
      {'name': 'Д', 'category': 'letter', 'description': 'Літера Д української дактильної абетки', 'created_at': now},
      {'name': 'Е', 'category': 'letter', 'description': 'Літера Е української дактильної абетки', 'created_at': now},
      {'name': 'Є', 'category': 'letter', 'description': 'Літера Є української дактильної абетки', 'created_at': now},
      {'name': 'Ж', 'category': 'letter', 'description': 'Літера Ж української дактильної абетки', 'created_at': now},
      {'name': 'З', 'category': 'letter', 'description': 'Літера З української дактильної абетки', 'created_at': now},
      {'name': 'И', 'category': 'letter', 'description': 'Літера И української дактильної абетки', 'created_at': now},
      {'name': 'І', 'category': 'letter', 'description': 'Літера І української дактильної абетки', 'created_at': now},
      {'name': 'Ї', 'category': 'letter', 'description': 'Літера Ї української дактильної абетки', 'created_at': now},
      {'name': 'Й', 'category': 'letter', 'description': 'Літера Й української дактильної абетки', 'created_at': now},
      {'name': 'К', 'category': 'letter', 'description': 'Літера К української дактильної абетки', 'created_at': now},
      {'name': 'Л', 'category': 'letter', 'description': 'Літера Л української дактильної абетки', 'created_at': now},
      {'name': 'М', 'category': 'letter', 'description': 'Літера М української дактильної абетки', 'created_at': now},
      {'name': 'Н', 'category': 'letter', 'description': 'Літера Н української дактильної абетки', 'created_at': now},
      {'name': 'О', 'category': 'letter', 'description': 'Літера О української дактильної абетки', 'created_at': now},
      {'name': 'П', 'category': 'letter', 'description': 'Літера П української дактильної абетки', 'created_at': now},
      {'name': 'Р', 'category': 'letter', 'description': 'Літера Р української дактильної абетки', 'created_at': now},
      {'name': 'С', 'category': 'letter', 'description': 'Літера С української дактильної абетки', 'created_at': now},
      {'name': 'Т', 'category': 'letter', 'description': 'Літера Т української дактильної абетки', 'created_at': now},
      {'name': 'У', 'category': 'letter', 'description': 'Літера У української дактильної абетки', 'created_at': now},
      {'name': 'Ф', 'category': 'letter', 'description': 'Літера Ф української дактильної абетки', 'created_at': now},
      {'name': 'Х', 'category': 'letter', 'description': 'Літера Х української дактильної абетки', 'created_at': now},
      {'name': 'Ц', 'category': 'letter', 'description': 'Літера Ц української дактильної абетки', 'created_at': now},
      {'name': 'Ч', 'category': 'letter', 'description': 'Літера Ч української дактильної абетки', 'created_at': now},
      {'name': 'Ш', 'category': 'letter', 'description': 'Літера Ш української дактильної абетки', 'created_at': now},
      {'name': 'Щ', 'category': 'letter', 'description': 'Літера Щ української дактильної абетки', 'created_at': now},
      {'name': 'Ь', 'category': 'letter', 'description': 'Літера Ь української дактильної абетки', 'created_at': now},
      {'name': 'Ю', 'category': 'letter', 'description': 'Літера Ю української дактильної абетки', 'created_at': now},
      {'name': 'Я', 'category': 'letter', 'description': 'Літера Я української дактильної абетки', 'created_at': now}
    ];

    // Цифри
    final numberGestures = [
      {'name': '0', 'category': 'number', 'description': 'Цифра 0 дактильної абетки', 'created_at': now},
      {'name': '1', 'category': 'number', 'description': 'Цифра 1 дактильної абетки', 'created_at': now},
      {'name': '2', 'category': 'number', 'description': 'Цифра 2 дактильної абетки', 'created_at': now},
      {'name': '3', 'category': 'number', 'description': 'Цифра 3 дактильної абетки', 'created_at': now},
      {'name': '4', 'category': 'number', 'description': 'Цифра 4 дактильної абетки', 'created_at': now},
      {'name': '5', 'category': 'number', 'description': 'Цифра 5 дактильної абетки', 'created_at': now},
      {'name': '6', 'category': 'number', 'description': 'Цифра 6 дактильної абетки', 'created_at': now},
      {'name': '7', 'category': 'number', 'description': 'Цифра 7 дактильної абетки', 'created_at': now},
      {'name': '8', 'category': 'number', 'description': 'Цифра 8 дактильної абетки', 'created_at': now},
      {'name': '9', 'category': 'number', 'description': 'Цифра 9 дактильної абетки', 'created_at': now},
    ];

    // Базові жести
    final generalGestures = [
      {'name': 'Привіт', 'category': 'general', 'description': 'Вітання', 'created_at': now},
      {'name': 'Дякую', 'category': 'general', 'description': 'Подяка', 'created_at': now},
      {'name': 'Будь ласка', 'category': 'general', 'description': 'Прохання', 'created_at': now},
      {'name': 'Так', 'category': 'general', 'description': 'Згода', 'created_at': now},
      {'name': 'Ні', 'category': 'general', 'description': 'Заперечення', 'created_at': now},
    ];

    // Додавання даних у базу
    for (var gesture in [...letterGestures, ...numberGestures, ...generalGestures]) {
      await db.insert(tableGestures, gesture);
    }

    // Додавання базових налаштувань
    final defaultSettings = [
      {'setting_name': 'recognition_threshold', 'setting_value': '0.85', 'updated_at': now},
      {'setting_name': 'bluetooth_auto_connect', 'setting_value': 'true', 'updated_at': now},
      {'setting_name': 'theme_mode', 'setting_value': 'light', 'updated_at': now},
      {'setting_name': 'language', 'setting_value': 'uk', 'updated_at': now},
      {'setting_name': 'use_text_to_speech', 'setting_value': 'false', 'updated_at': now},
    ];

    for (var setting in defaultSettings) {
      await db.insert(tableUserSettings, setting);
    }
  }

  /// Закриття бази даних
  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}