import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/web_dashboard_controller.dart';
import '../models/web_job_card.dart';
import '../web_shell.dart';
import '../web_theme.dart';
import '../web_widgets.dart';

class WebDashboardPage extends StatelessWidget {
  const WebDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WebDashboardController>();
    final shell = Get.find<WebShellController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(WebSpace.page, WebSpace.page, WebSpace.page, 0),
          child: WebPageHeader(
            title: 'Dashboard',
            subtitle: Obx(() {
              final t = c.lastUpdated.value;
              return Text(t == null ? fmtDate(DateTime.now()) : 'Updated ${fmtDateTime(t)}');
            }),
            actions: [
              Obx(
                () => OutlinedButton.icon(
                  onPressed: c.loading.value ? null : c.load,
                  icon: c.loading.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(WebSpace.page),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: WebSpace.contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() {
                      final err = c.error.value;
                      if (err == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ErrorBanner(err),
                      );
                    }),
                    LayoutBuilder(builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final cols = w >= 1100 ? 4 : (w >= 640 ? 2 : 1);
                      final tileWidth = (w - WebSpace.gap * (cols - 1)) / cols;
                      return Obx(
                        () => Wrap(
                          spacing: WebSpace.gap,
                          runSpacing: WebSpace.gap,
                          children: [
                            SizedBox(
                              width: tileWidth,
                              child: WebStatTile(
                                label: 'New cards',
                                value: c.openCount.value,
                                icon: Icons.inbox_outlined,
                                color: WebColors.brand,
                                tint: WebColors.brandTint,
                                onTap: () => shell.select(1),
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: WebStatTile(
                                label: 'Finished cards',
                                value: c.finishedCount.value,
                                icon: Icons.task_alt_outlined,
                                color: WebColors.green,
                                tint: WebColors.greenTint,
                                onTap: () => shell.select(2),
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: WebStatTile(
                                label: 'Received today',
                                value: c.todayCount.value,
                                icon: Icons.today_outlined,
                                color: WebColors.blue,
                                tint: WebColors.blueTint,
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: WebStatTile(
                                label: 'Received this week',
                                value: c.weekCount.value,
                                icon: Icons.date_range_outlined,
                                color: WebColors.amber,
                                tint: WebColors.amberTint,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: WebSpace.page),
                    WebSurface(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WebSectionTitle(
                            'Recent cards',
                            trailing: TextButton(
                              onPressed: () => shell.select(1),
                              child: const Text('View new cards'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            if (c.loading.value && c.recent.isEmpty) {
                              return Column(
                                children: List.generate(
                                  4,
                                  (_) => const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      children: [
                                        WebSkeletonLine(width: 220),
                                        Spacer(),
                                        WebSkeletonLine(width: 90),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (c.recent.isEmpty) {
                              return const WebEmptyState(
                                icon: Icons.inbox_outlined,
                                title: 'No cards yet',
                                message: 'Cards added from the mobile app appear here.',
                              );
                            }
                            return Column(
                              children: [
                                for (final card in c.recent) _RecentRow(card),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow(this.card);

  final WebJobCard card;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 640;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: WebColors.hover,
        onTap: () => Get.toNamed('/card/${card.id}'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: WebColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [card.customerName, card.plateNumber]
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: WebColors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!narrow)
                Expanded(
                  flex: 2,
                  child: Text(
                    card.timestamp != null ? fmtDateTime(card.timestamp) : card.date,
                    style: const TextStyle(color: WebColors.muted, fontSize: 13),
                  ),
                ),
              WebStatusChip(open: card.open, compact: true),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: WebColors.subtle),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: WebColors.brandTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: WebColors.brand, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: WebColors.brandDark))),
        ],
      ),
    );
  }
}
