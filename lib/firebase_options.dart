import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not supported');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUpDVgDy5CklmNvlaBRdL1W8t26tGILxU',
    appId: '1:517335557294:android:a504fc0ae2325b51dab93f',
    messagingSenderId: '517335557294',
    projectId: 'krishi-bondhu-app',
    storageBucket: 'krishi-bondhu-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBUpDVgDy5CklmNvlaBRdL1W8t26tGILxU',
    appId: '1:517335557294:ios:PLACEHOLDER',
    messagingSenderId: '517335557294',
    projectId: 'krishi-bondhu-app',
    storageBucket: 'krishi-bondhu-app.firebasestorage.app',
    iosBundleId: 'com.example.krishiBondhuAppBd',
  );
}