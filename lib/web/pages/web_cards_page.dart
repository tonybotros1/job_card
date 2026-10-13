import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/web_cards_controller.dart';
import '../models/web_job_card.dart';
import '../web_images.dart';
import '../web_shell.dart';
import '../web_theme.dart';
import '../web_widgets.dart';

/// New cards / Finished cards list with search and a grid / table toggle.
class WebCardsPage extends StatefulWidget {
  const WebCardsPage({super.key, required this.open});

  final bool open;

  @override
  State<WebCardsPage> createState() => _WebCardsPageState();
}

class _WebCardsPageState extends State<WebCardsPage> {
  late final WebCardsController c =
      Get.find<WebCardsController>(tag: widget.open ? 'open' : 'finished');
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (c.query.value.isNotEmpty) return;
      final pos = _scroll.position;
      if (pos.pixels > pos.maxScrollExtent - 600) c.loadMore();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.open ? 'New cards' : 'Finished cards';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(WebSpace.page, WebSpace.page, WebSpace.page, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WebPageHeader(
                title: title,
                subtitle: Obx(() {
                  final total = c.total.value;
                  if (c.query.value.isNotEmpty) {
                    return Text(c.searching.value
                        ? 'Searching…'
                        : '${fmtInt(c.results.length)} of ${total == null ? '' : fmtInt(total)} cards match');
                  }
                  return Text(total == null
                      ? '${fmtInt(c.cards.length)} loaded'
                      : '${fmtInt(total)} cards · ${fmtInt(c.cards.length)} loaded');
                }),
                actions: [
                  Obx(
                    () => SegmentedButton<bool>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        side: const WidgetStatePropertyAll(BorderSide(color: WebColors.border)),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (s) => s.contains(WidgetState.selected) ? WebColors.brandTint : WebColors.surface,
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (s) => s.contains(WidgetState.selected) ? WebColors.brand : WebColors.muted,
                        ),
                      ),
                      segments: const [
                        ButtonSegment(value: true, icon: Icon(Icons.grid_view, size: 18), tooltip: 'Grid'),
                        ButtonSegment(value: false, icon: Icon(Icons.table_rows_outlined, size: 18), tooltip: 'Table'),
                      ],
                      selected: {c.gridView.value},
                      onSelectionChanged: (s) => c.setGridView(s.first),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: WebSearchField(
                  controller: _search,
                  hint: 'Search by brand, model, plate, date or customer',
                  onChanged: c.onQueryChanged,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (c.loading.value) {
              return const Center(child: CircularProgressIndicator(color: WebColors.brand));
            }
            final searchMode = c.query.value.isNotEmpty;
            final list = searchMode ? c.results : c.cards;
            if (searchMode && c.searching.value && list.isEmpty) {
              return const _Centered(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: WebColors.brand),
                    SizedBox(height: 14),
                    Text('Searching all cards…', style: TextStyle(color: WebColors.muted)),
                  ],
                ),
              );
            }
            if (list.isEmpty) {
              return WebEmptyState(
                icon: searchMode ? Icons.search_off : Icons.inbox_outlined,
                title: searchMode ? 'No cards match' : 'No $title',
                message: searchMode
                    ? 'Try another brand, plate number, date or customer name.'
                    : 'Cards added from the mobile app appear here.',
              );
            }
            return CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(WebSpace.page, 4, WebSpace.page, 8),
                  sliver: c.gridView.value ? _grid(list) : _table(list, context),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 4)),
                SliverToBoxAdapter(child: _footer()),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _grid(List<WebJobCard> list) {
    // Four posters per row on desktop; fewer as the window narrows.
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100 ? 4 : (width >= 820 ? 3 : (width >= 560 ? 2 : 1));
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: _posterHeight,
        crossAxisSpacing: WebSpace.gap,
        mainAxisSpacing: WebSpace.gap,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) => _CardTile(list[i]),
    );
  }

  Widget _table(List<WebJobCard> list, BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 900;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _TableHeader(narrow: narrow)),
        SliverList.builder(
          itemCount: list.length,
          itemBuilder: (context, i) => _TableRow(list[i], narrow: narrow, last: i == list.length - 1),
        ),
      ],
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(WebSpace.page, 8, WebSpace.page, WebSpace.page),
      child: Center(
        child: Obx(() {
          // Read the observables first: Obx needs at least one on every build.
          final searchMode = c.query.value.isNotEmpty;
          final loadingMore = c.loadingMore.value;
          final hasMore = c.hasMore.value;
          final loaded = c.cards.length;
          if (searchMode) return const SizedBox.shrink();
          if (loadingMore) {
            return const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: WebColors.brand),
              ),
            );
          }
          if (hasMore) {
            return OutlinedButton(onPressed: c.loadMore, child: const Text('Load more'));
          }
          return Text(
            'All ${fmtInt(loaded)} cards loaded',
            style: const TextStyle(color: WebColors.subtle, fontSize: 13),
          );
        }),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(child: child);
}

void _openCard(WebJobCard card) => Get.toNamed('/card/${card.id}');

void _share(BuildContext context, WebJobCard card) {
  Share.share(card.shareText).catchError((_) {
    if (context.mounted) webToast(context, 'Sharing is not available in this browser');
    return ShareResult.unavailable;
  });
}

const _coverHeight = 190.0;
const _posterHeight = _coverHeight + 84;

/// Poster-style card: cover photo with the title over it, details underneath.
class _CardTile extends StatelessWidget {
  const _CardTile(this.card);

  final WebJobCard card;

  @override
  Widget build(BuildContext context) {
    return WebHoverCard(
      onTap: () => _openCard(card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Cover(card: card),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Line(
                  Icons.person_outline,
                  card.customerName.isEmpty ? 'No customer name' : card.customerName,
                ),
                const SizedBox(height: 6),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: WebColors.text,
                            letterSpacing: 0.3,
                          ),
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
                    IconButton(
                      tooltip: 'Share with customer',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                      iconSize: 18,
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () => _share(context, card),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.card});

  final WebJobCard card;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = card.carImages.isNotEmpty;
    return SizedBox(
      height: _coverHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasPhoto)
            WebNetworkImage(
              url: card.carImages.first,
              memCacheWidth: 700,
              placeholder: const _CoverPlaceholder(),
            )
          else
            const _CoverPlaceholder(),
          // Dark gradient so the title stays readable on any photo.
          if (hasPhoto)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.35, 1],
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Text(
              card.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasPhoto ? Colors.white : WebColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
                shadows: hasPhoto ? const [Shadow(color: Colors.black45, blurRadius: 6)] : null,
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: WebStatusChip(open: card.open, compact: true),
          ),
          if (card.carImages.length > 1)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_library_outlined, size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${card.carImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WebColors.bg,
      child: const Center(
        child: Icon(Icons.directions_car_outlined, size: 40, color: WebColors.subtle),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: WebColors.subtle),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: WebColors.muted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

const _colVehicle = 3;
const _colCustomer = 3;
const _colPlate = 2;
const _colColour = 2;
const _colDate = 2;

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.narrow});
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WebColors.muted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: WebColors.surface,
        border: Border(
          top: BorderSide(color: WebColors.border),
          left: BorderSide(color: WebColors.border),
          right: BorderSide(color: WebColors.border),
          bottom: BorderSide(color: WebColors.border),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(WebSpace.radius)),
      ),
      child: const Row(
        children: [
          Expanded(flex: _colVehicle, child: Text('Vehicle', style: style)),
          Expanded(flex: _colCustomer, child: Text('Customer', style: style)),
          Expanded(flex: _colPlate, child: Text('Plate', style: style)),
          Expanded(flex: _colColour, child: Text('Colour', style: style)),
          Expanded(flex: _colDate, child: Text('Received', style: style)),
          SizedBox(width: 96, child: Text('Status', style: style)),
          SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow(this.card, {required this.narrow, required this.last});
  final WebJobCard card;
  final bool narrow;
  final bool last;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 13.5, color: WebColors.text);
    const mutedStyle = TextStyle(fontSize: 13.5, color: WebColors.muted);
    return Material(
      color: WebColors.surface,
      child: InkWell(
        hoverColor: WebColors.hover,
        onTap: () => _openCard(card),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              left: const BorderSide(color: WebColors.border),
              right: const BorderSide(color: WebColors.border),
              bottom: const BorderSide(color: WebColors.border),
            ),
            borderRadius: last
                ? const BorderRadius.vertical(bottom: Radius.circular(WebSpace.radius))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                flex: _colVehicle,
                child: Text(card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.copyWith(fontWeight: FontWeight.w600)),
              ),
              Expanded(
                flex: _colCustomer,
                child: Text(card.customerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
              ),
              Expanded(
                flex: _colPlate,
                child: Text(card.plateNumber, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
              ),
              Expanded(
                flex: _colColour,
                child: Text(card.color, maxLines: 1, overflow: TextOverflow.ellipsis, style: mutedStyle),
              ),
              Expanded(
                flex: _colDate,
                child: Text(card.date, maxLines: 1, overflow: TextOverflow.ellipsis, style: mutedStyle),
              ),
              SizedBox(
                width: 96,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: WebStatusChip(open: card.open, compact: true),
                ),
              ),
              SizedBox(
                width: 40,
                child: IconButton(
                  tooltip: 'Share with customer',
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _share(context, card),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
