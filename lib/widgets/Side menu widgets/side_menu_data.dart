import 'package:flutter/material.dart';
import '../../models/side_menu_model.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    // MenuModel(icon: Icons.dashboard, title: 'Dashboard'),
    MenuModel(icon: Icons.home_outlined, title: 'New Cards'),
    MenuModel(icon: Icons.done_all, title: 'Finished Cards'),
  ];
}
