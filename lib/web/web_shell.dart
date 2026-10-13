import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/web_cards_controller.dart';
import 'controllers/web_dashboard_controller.dart';
import 'controllers/web_orphans_controller.dart';
import 'pages/web_cards_page.dart';
import 'pages/web_dashboard_page.dart';
import 'pages/web_orphans_page.dart';
import 'web_theme.dart';
import 'web_widgets.dart';

/// Shown at the bottom of the side navigation so a stale browser build is
/// easy to spot (bump it with every deploy).
const kWebBuild = '13 Oct 2026 · 5';

class WebShellController extends GetxController {
  final index = 0.obs;
  final collapsed = false.obs;

  void select(int i) => index.value = i;
  void toggleCollapsed() => collapsed.value = !collapsed.value;

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceToken', '');
    await prefs.setString('userId', '');
    Get.offAllNamed('/loginScreen');
  }
}

/// The signed-in web workspace: side navigation + Dashboard / New / Finished.
/// Pages live in an [IndexedStack] so switching tabs never refetches.
class WebShell extends StatelessWidget {
  const WebShell({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.put(WebShellController());
    Get.put(WebCardsController(open: true), tag: 'open');
    Get.put(WebCardsController(open: false), tag: 'finished');
    Get.put(WebDashboardController());
    Get.put(WebOrphansController());

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final narrow = width < WebBreakpoints.medium;
      final wide = width >= WebBreakpoints.wide;
      return Scaffold(
        drawer: narrow
            ? const Drawer(width: 264, child: WebSideNav(expanded: true, inDrawer: true))
            : null,
        body: Row(
          children: [
            if (!narrow)
              Obx(() => WebSideNav(expanded: wide && !shell.collapsed.value, canCollapse: wide)),
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: shell.index.value,
                  children: const [
                    WebDashboardPage(),
                    WebCardsPage(open: true),
                    WebCardsPage(open: false),
                    WebOrphansPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const _items = [
  _NavItem('Dashboard', Icons.space_dashboard_outlined, Icons.space_dashboard),
  _NavItem('New cards', Icons.inbox_outlined, Icons.inbox),
  _NavItem('Finished cards', Icons.task_alt_outlined, Icons.task_alt),
  _NavItem('Old data', Icons.inventory_2_outlined, Icons.inventory_2),
];

class WebSideNav extends StatelessWidget {
  const WebSideNav({
    super.key,
    required this.expanded,
    this.inDrawer = false,
    this.canCollapse = false,
  });

  final bool expanded;
  final bool inDrawer;
  final bool canCollapse;

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<WebShellController>();
    final openCards = Get.find<WebCardsController>(tag: 'open');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: expanded ? 240 : 72,
      decoration: const BoxDecoration(
        color: WebColors.surface,
        border: Border(right: BorderSide(color: WebColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Image.asset('assets/logo2.png', height: 36, width: 36, fit: BoxFit.contain),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Compass',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text('Job Card',
                            style: TextStyle(color: WebColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          for (var i = 0; i < _items.length; i++)
            Obx(() {
              final selected = shell.index.value == i;
              final badge = i == 1 ? openCards.total.value : null;
              return _NavTile(
                item: _items[i],
                selected: selected,
                expanded: expanded,
                badge: badge,
                onTap: () {
                  shell.select(i);
                  if (inDrawer) Navigator.of(context).pop();
                },
              );
            }),
          const Spacer(),
          if (canCollapse)
            _NavButton(
              icon: expanded ? Icons.keyboard_double_arrow_left : Icons.keyboard_double_arrow_right,
              label: 'Collapse',
              expanded: expanded,
              onTap: shell.toggleCollapsed,
            ),
          _NavButton(
            icon: Icons.logout,
            label: 'Log out',
            expanded: expanded,
            color: WebColors.brand,
            onTap: () async {
              final ok = await webConfirm(
                context,
                title: 'Log out?',
                message: 'You will need your e-mail and password to sign in again.',
                confirmLabel: 'Log out',
                danger: true,
              );
              if (ok) shell.logOut();
            },
          ),
          if (expanded)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Text('Build $kWebBuild',
                  style: TextStyle(color: WebColors.subtle, fontSize: 11)),
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.expanded,
    required this.onTap,
    this.badge,
  });

  final _NavItem item;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final color = selected ? WebColors.brand : WebColors.muted;
    final tile = Material(
      color: selected ? WebColors.brandTint : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: WebColors.hover,
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(selected ? item.activeIcon : item.icon, size: 21, color: color),
              if (expanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? WebColors.brand : WebColors.text,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: selected ? WebColors.brand : WebColors.bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      fmtInt(badge!),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : WebColors.muted,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: expanded ? tile : Tooltip(message: item.label, child: tile),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.onTap,
    this.color = WebColors.muted,
  });

  final IconData icon;
  final String label;
  final bool expanded;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tile = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: WebColors.hover,
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              if (expanded) ...[
                const SizedBox(width: 12),
                Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ),
      ),
    );
    return expanded ? tile : Tooltip(message: label, child: tile);
  }
}

/// Title row at the top of each page. Shows the drawer button on narrow screens.
class WebPageHeader extends StatelessWidget {
  const WebPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final Widget? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final hasDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasDrawer)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                DefaultTextStyle(
                  style: const TextStyle(color: WebColors.muted, fontSize: 13),
                  child: subtitle!,
                ),
              ],
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}
