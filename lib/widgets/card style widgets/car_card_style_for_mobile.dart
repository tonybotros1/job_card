import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/card_navigation.dart';
import '../../web/controllers/web_cards_controller.dart';
import '../../web/models/web_job_card.dart';
import '../../web/web_images.dart';
import '../../web/web_theme.dart';
import '../../web/web_widgets.dart';

/// Paged list of job cards for the phone: loads 48 at a time and fetches more
/// as you scroll. [header] is shown above the first card (e.g. the stats strip).
class MobileCardList extends StatefulWidget {
  const MobileCardList({
    super.key,
    required this.controller,
    this.header,
    this.emptyTitle = 'No cards',
    this.emptyMessage,
  });

  final WebCardsController controller;
  final Widget? header;
  final String emptyTitle;
  final String? emptyMessage;

  @override
  State<MobileCardList> createState() => _MobileCardListState();
}

class _MobileCardListState extends State<MobileCardList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final pos = _scroll.position;
      if (pos.pixels > pos.maxScrollExtent - 800) widget.controller.loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Obx(() {
      final cards = c.cards;
      final headerCount = widget.header == null ? 0 : 1;
      if (cards.isEmpty) {
        // AlwaysScrollable so pull-to-refresh works even with nothing to scroll.
        return ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (widget.header != null) widget.header!,
            SizedBox(
              height: 360,
              child: WebEmptyState(
                icon: c.open ? Icons.inbox_outlined : Icons.task_alt_outlined,
                title: widget.emptyTitle,
                message: widget.emptyMessage,
              ),
            ),
          ],
        );
      }
      return ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: headerCount + cards.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          if (widget.header != null && i == 0) return widget.header!;
          final index = i - headerCount;
          if (index == cards.length) return _Footer(controller: c);
          return MobileCardTile(card: cards[index]);
        },
      );
    });
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller});
  final WebCardsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loadingMore = controller.loadingMore.value;
      final hasMore = controller.hasMore.value;
      final loaded = controller.cards.length;
      final total = controller.total.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: loadingMore
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: WebColors.brand),
                )
              : hasMore
                  ? OutlinedButton(onPressed: controller.loadMore, child: const Text('Load more'))
                  : Text(
                      total == null ? 'All $loaded cards loaded' : 'All ${fmtInt(total)} cards loaded',
                      style: const TextStyle(color: WebColors.subtle, fontSize: 13),
                    ),
        ),
      );
    });
  }
}

/// Search screen for a paged list: the full list is fetched once, then every
/// keystroke filters in memory.
class MobileCardSearch extends SearchDelegate<void> {
  MobileCardSearch(this.controller)
      : super(searchFieldLabel: 'Brand, model, plate, date or customer');

  final WebCardsController controller;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        titleTextStyle: const TextStyle(fontSize: 16, color: WebColors.text),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: WebColors.subtle, fontSize: 16),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(onPressed: () => query = '', icon: const Icon(Icons.close)),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    controller.onQueryChanged(query);
    if (query.trim().isEmpty) {
      return const WebEmptyState(
        icon: Icons.search,
        title: 'Search cards',
        message: 'Type a brand, model, plate number, date or customer name.',
      );
    }
    return Obx(() {
      final results = controller.results;
      if (controller.searching.value && results.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: WebColors.brand));
      }
      if (results.isEmpty) {
        return const WebEmptyState(icon: Icons.search_off, title: 'No cards match');
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => MobileCardTile(card: results[i]),
      );
    });
  }
}

class MobileCardTile extends StatelessWidget {
  const MobileCardTile({super.key, required this.card});

  final WebJobCard card;

  void _open() => card.partial ? openCardById(card.id) : openCardDetails(card);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WebColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WebSpace.radius),
        side: const BorderSide(color: WebColors.border),
      ),
      child: InkWell(
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: card.carImages.isEmpty
                      ? const ColoredBox(
                          color: WebColors.bg,
                          child: Icon(Icons.directions_car_outlined,
                              color: WebColors.subtle, size: 32),
                        )
                      : WebNetworkImage(url: card.carImages.first, memCacheWidth: 300),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            card.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700, height: 1.2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        WebStatusChip(open: card.open, compact: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.customerName.isEmpty ? 'No customer name' : card.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: WebColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (card.plateNumber.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: WebColors.bg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: WebColors.border),
                            ),
                            child: Text(
                              card.plateNumber,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            card.date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: WebColors.muted, fontSize: 12.5),
                          ),
                        ),
                        if (card.carImages.length > 1) ...[
                          const Icon(Icons.photo_library_outlined,
                              size: 14, color: WebColors.subtle),
                          const SizedBox(width: 3),
                          Text('${card.carImages.length}',
                              style: const TextStyle(color: WebColors.subtle, fontSize: 12)),
                          const SizedBox(width: 4),
                        ],
                        IconButton(
                          tooltip: 'Share with customer',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                          iconSize: 18,
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () async => Share.share((await card.complete()).shareText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
