// File generated manually / via FlutterFire CLI for finflow-app-9972.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDsTQiT-le0srXq2E7awecNPw_On2_MfOY',
    appId: '1:674641773932:web:finflowapp9972web',
    messagingSenderId: '674641773932',
    projectId: 'finflow-app-9972',
    authDomain: 'finflow-app-9972.firebaseapp.com',
    storageBucket: 'finflow-app-9972.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsTQiT-le0srXq2E7awecNPw_On2_MfOY',
    appId: '1:674641773932:android:6db4d0bf89305a3022df49',
    messagingSenderId: '674641773932',
    projectId: 'finflow-app-9972',
    storageBucket: 'finflow-app-9972.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsTQiT-le0srXq2E7awecNPw_On2_MfOY',
    appId: '1:674641773932:ios:6db4d0bf89305a3022df49',
    messagingSenderId: '674641773932',
    projectId: 'finflow-app-9972',
    storageBucket: 'finflow-app-9972.firebasestorage.app',
    iosBundleId: 'com.example.finflow',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDsTQiT-le0srXq2E7awecNPw_On2_MfOY',
    appId: '1:674641773932:ios:6db4d0bf89305a3022df49',
    messagingSenderId: '674641773932',
    projectId: 'finflow-app-9972',
    storageBucket: 'finflow-app-9972.firebasestorage.app',
    iosBundleId: 'com.example.finflow',
  );
}
