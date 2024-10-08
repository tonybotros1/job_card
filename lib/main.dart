import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // Add this import

import 'screens/Cards screens/card_details_screen.dart';
import 'screens/Cards screens/card_details_screen_for_web.dart';
import 'screens/Cards screens/card_images_screen.dart';
import 'screens/Cards screens/edit_card_screen.dart';
import 'screens/Cards screens/main_cards_screen.dart';
import 'screens/auth/loading_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/images and videos screens/images_screen.dart';
import 'screens/images and videos screens/single_image_viewer.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDQE2wU5fSbsePR5XAzhxRhHv3eHppwv94",
            authDomain: "job-card-62478.firebaseapp.com",
            projectId: "job-card-62478",
            storageBucket: "job-card-62478.appspot.com",
            messagingSenderId: "9681419746",
            appId: "1:9681419746:web:4f6f116df48e511f47cdbb",
            measurementId: "G-LDQZ5NLESB"));
  } else {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyB2ql5CI0sSUQ0igdwh0G1Bmsu6TUtBpIw',
      appId: '1:9681419746:android:278788a51a443d7647cdbb',
      messagingSenderId: '9681419746',
      storageBucket: 'job-card-62478.appspot.com',
      projectId: 'job-card-62478',
    ));
  }
  // await FirebaseAppCheck.instance.activate(
  //   webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
  //   androidProvider: AndroidProvider.debug,
  // );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home:const LoadingScreen(),
      getPages: [
        GetPage(name:'/' , page: () => const LoadingScreen()),
        GetPage(name: '/loginScreen', page:()=> LoginScreen()),
        GetPage(name: '/mainCardsScreen', page: ()=> const MainCardsScreen()),
        GetPage(name: '/editCardScreen', page: ()=> EditCardScreen()),
        GetPage(name: '/cardImagesScreen', page: ()=>CardImagesScreen()),
        GetPage(name: '/singleImageViewer', page:()=> SingleImageViewer()),
        GetPage(name: '/imagesScreen', page: ()=> ImagesScreen()),
        GetPage(name: '/carDetailsScreen', page: ()=> CarDetailsScreen()),
        GetPage(name: '/cardDetailsScreenForWeb', page: ()=> CardDetailsScreenForWeb())
      ],
    );
  }
}
