// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCDydJOA6JH2T05HvF8GuDiAbCmwhs8nG0',
    appId: '1:762834039807:web:fb2e34475336fde6e6adca',
    messagingSenderId: '762834039807',
    projectId: 'restroio',
    authDomain: 'restroio.firebaseapp.com',
    storageBucket: 'restroio.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9TDi3CsUSqeIBNA99rxSYKgIr2YJjCUQ',
    appId: '1:762834039807:android:e4ad13df5abd55d5e6adca',
    messagingSenderId: '762834039807',
    projectId: 'restroio',
    storageBucket: 'restroio.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXUXblsErHI8pl-jwR88yTwla8tCmprMk',
    appId: '1:762834039807:ios:3e2caab60edc5786e6adca',
    messagingSenderId: '762834039807',
    projectId: 'restroio',
    storageBucket: 'restroio.appspot.com',
    iosClientId: '762834039807-5lvfsmnud64admgs78rp5ssh2bbm058i.apps.googleusercontent.com',
    iosBundleId: 'app.restro.mobile.restro',
  );
}