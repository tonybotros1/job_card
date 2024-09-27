import 'package:flutter/material.dart';

class ScreenSize extends StatelessWidget {
  const ScreenSize({super.key, required this.web, required this.notWeb, required this.mobile});

  final Widget web;
  final Widget notWeb;
  final Widget mobile;

  // Static method to determine if it's a web screen
  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 700;
  }

  static bool isNotWeb(BuildContext context) {
    return MediaQuery.of(context).size.width < 700;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 500;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (size.width > 700) {
      return web;
    } else if (size.width < 700) {
      return notWeb;
    } else {
      return mobile;
    }
  }
}
