import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../web/controllers/web_cards_controller.dart';
import '../../web/web_theme.dart';
import '../../web/web_widgets.dart';
import '../../widgets/card style widgets/car_card_style_for_mobile.dart';

/// Done tab of the phone app: finished cards, paged.
class FinishedWorksScreen extends StatelessWidget {
  FinishedWorksScreen({super.key});

  final WebCardsController cards = Get.put(WebCardsController(open: false), tag: 'finished');

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
              const Text('Finished cards'),
              if (total != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: WebColors.greenTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    fmtInt(total),
                    style: const TextStyle(
                        color: WebColors.green, fontSize: 12, fontWeight: FontWeight.w600),
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
            emptyTitle: 'No finished cards',
            emptyMessage: 'Cards marked as finished appear here.',
          ),
        );
      }),
    );
  }
}
