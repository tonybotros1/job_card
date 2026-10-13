import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signs out of Firebase, clears the stored session and returns to sign-in.
Future<void> signOutToLogin() async {
  await FirebaseAuth.instance.signOut();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('deviceToken', '');
  await prefs.setString('userId', '');
  Get.offAllNamed('/loginScreen');
}
