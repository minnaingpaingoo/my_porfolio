import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for project `my-portfolio-b1b1c` (Web & Android).
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
        return windows;
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyC9cXzjDsJAd1pDjfoHErELhHBUuzqU3hs",
    authDomain: "my-portfolio-b1b1c.firebaseapp.com",
    projectId: "my-portfolio-b1b1c",
    storageBucket: "my-portfolio-b1b1c.firebasestorage.app",
    messagingSenderId: "898338374369",
    appId: "1:898338374369:web:cb5924559dace5ea65ada0",
    measurementId: "G-QXRYL4GPVT",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlnr1AY5o2Jw-dSi4SMNThKThNR44H5Xw',
    appId: '1:898338374369:android:14f545f78a6becd465ada0',
    messagingSenderId: '898338374369',
    projectId: 'my-portfolio-b1b1c',
    storageBucket: 'my-portfolio-b1b1c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBlnr1AY5o2Jw-dSi4SMNThKThNR44H5Xw',
    appId: '1:898338374369:android:14f545f78a6becd465ada0',
    messagingSenderId: '898338374369',
    projectId: 'my-portfolio-b1b1c',
    storageBucket: 'my-portfolio-b1b1c.firebasestorage.app',
    iosBundleId: 'com.example.myPorfolio',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBlnr1AY5o2Jw-dSi4SMNThKThNR44H5Xw',
    appId: '1:898338374369:android:14f545f78a6becd465ada0',
    messagingSenderId: '898338374369',
    projectId: 'my-portfolio-b1b1c',
    storageBucket: 'my-portfolio-b1b1c.firebasestorage.app',
    iosBundleId: 'com.example.myPorfolio',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyC9cXzjDsJAd1pDjfoHErELhHBUuzqU3hs",
    authDomain: "my-portfolio-b1b1c.firebaseapp.com",
    projectId: "my-portfolio-b1b1c",
    storageBucket: "my-portfolio-b1b1c.firebasestorage.app",
    messagingSenderId: "898338374369",
    appId: "1:898338374369:web:cb5924559dace5ea65ada0",
    measurementId: "G-QXRYL4GPVT",
  );
}
