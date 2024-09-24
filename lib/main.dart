import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // Add this import

import 'screens/auth/loading_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid || Platform.isIOS
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
          apiKey: 'AIzaSyB2ql5CI0sSUQ0igdwh0G1Bmsu6TUtBpIw',
          appId: '1:9681419746:android:278788a51a443d7647cdbb',
          messagingSenderId: '9681419746',
          storageBucket: 'job-card-62478.appspot.com',
          projectId: 'job-card-62478',
        ))
      : kIsWeb
          ? await Firebase.initializeApp(
              options: const FirebaseOptions(
                  apiKey: "AIzaSyDQE2wU5fSbsePR5XAzhxRhHv3eHppwv94",
                  authDomain: "job-card-62478.firebaseapp.com",
                  projectId: "job-card-62478",
                  storageBucket: "job-card-62478.appspot.com",
                  messagingSenderId: "9681419746",
                  appId: "1:9681419746:web:4f6f116df48e511f47cdbb",
                  measurementId: "G-LDQZ5NLESB"))
          : await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
    );
  }
}
