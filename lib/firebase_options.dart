import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions не налаштовані для ${defaultTargetPlatform.name}',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0wOR3kQaZUSRQpzg0x7j8IWKtlNxQgYI',
    appId: '1:993675973198:android:18a5a006ab16bbf81a291f',
    messagingSenderId: '993675973198',
    projectId: 'haptica-bc48a',
    storageBucket: 'haptica-bc48a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'DUMMY_API_KEY_FOR_IOS',
    appId: 'DUMMY_APP_ID_FOR_IOS',
    messagingSenderId: '993675973198',
    projectId: 'haptica-bc48a',
    storageBucket: 'haptica-bc48a.firebasestorage.app',
    iosClientId: 'DUMMY_CLIENT_ID_FOR_IOS',
    iosBundleId: 'com.example.haptica',
  );
}