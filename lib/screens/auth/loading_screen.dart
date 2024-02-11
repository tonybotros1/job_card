import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const.dart';
import '../../controllers/Auth controllers/loading_screen_controller.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoadingScreenController>(
        init: LoadingScreenController(),
        builder: (controller) {
          return SafeArea(
              child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: mainColor),
            ),
          ));
        });
  }
}
