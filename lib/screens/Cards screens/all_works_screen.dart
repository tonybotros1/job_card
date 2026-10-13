import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/session.dart';
import '../../web/controllers/web_cards_controller.dart';
import '../../web/web_theme.dart';
import '../../web/web_widgets.dart';
import '../../widgets/card style widgets/car_card_style_for_mobile.dart';

/// Home tab of the phone app: the new (open) cards, paged.
class AllWorksScreen extends StatelessWidget {
  AllWorksScreen({super.key});

  final WebCardsController cards = Get.put(WebCardsController(open: true), tag: 'open');

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await webConfirm(
      context,
      title: 'Log out?',
      message: 'You will need your e-mail and password to sign in again.',
      confirmLabel: 'Log out',
      danger: true,
    );
    if (ok) await signOutToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Obx(() {
          final total = cards.total.value;
          return Row(
            children: [
              const Text('New cards'),
              if (total != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: WebColors.brandTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    fmtInt(total),
                    style: const TextStyle(
                        color: WebColors.brand, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          );
        }),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => showSearch(context: context, delegate: MobileCardSearch(cards)),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout, color: WebColors.brand),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (cards.loading.value) {
          return const Center(child: CircularProgressIndicator(color: WebColors.brand));
        }
        return RefreshIndicator(
          color: WebColors.brand,
          onRefresh: cards.reload,
          child: MobileCardList(
            controller: cards,
            emptyTitle: 'No new cards',
            emptyMessage: 'Cards you add appear here until they are finished.',
          ),
        );
      }),
    );
  }
}
