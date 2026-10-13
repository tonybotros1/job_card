import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../widgets/Main screen widgets/main_cards_screen_widget_for_mobile.dart';
import '../../web/web_shell.dart';

class MainCardsScreen extends StatelessWidget {
  const MainCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? const WebShell() : MainScreenForMobile();
  }
}
