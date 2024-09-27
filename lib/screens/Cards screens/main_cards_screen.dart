import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../widgets/main_cards_screen_widget_for_mobile.dart';
import '../../widgets/main_cards_screen_widget_for_web.dart';

class MainCardsScreen extends StatelessWidget {
  const MainCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? MainScreenForWeb() : MainScreenForMobile();
  }
}
