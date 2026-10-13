import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/Auth controllers/login_screen_controller.dart';
import '../../web/pages/web_login_page.dart';

/// Sign-in screen. The same page serves the phone and the browser.
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginScreenController loginScreenController = Get.put(LoginScreenController());

  @override
  Widget build(BuildContext context) => const WebLoginPage();
}
