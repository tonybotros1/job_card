import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/image_cache.dart';
import '../../models/job_card_model.dart';
import '../controllers/web_card_details_controller.dart';
import '../controllers/web_cards_controller.dart';
import '../controllers/web_dashboard_controller.dart';
import '../models/web_job_card.dart';
import '../web_images.dart';
import '../web_photo_viewer.dart';
import '../web_theme.dart';
import '../web_widgets.dart';

/// Card details for the web. Opened as `/card/:id`, so the page survives a
/// browser refresh; the legacy `/cardDetailsScreenForWeb` route with a
/// [JobCardModel] argument still works.
class WebCardDetailsPage extends StatelessWidget {
  const WebCardDetailsPage({super.key});

  String? _cardId() {
    final fromRoute = Get.parameters['id'];
    if (fromRoute != null && fromRoute.isNotEmpty) return fromRoute;
    final args = Get.arguments;
    if (args is JobCardModel) return args.docID;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final id = _cardId();
    if (id == null) {
      return Scaffold(
        backgroundColor: WebColors.bg,
        body: WebEmptyState(
          icon: Icons.link_off,
          title: 'No card selected',
          action: ElevatedButton(onPressed: _goHome, child: const Text('Back to cards')),
        ),
      );
    }
    final c = Get.put(WebCardDetailsController(id), tag: id);

    return Scaffold(
      backgroundColor: WebColors.bg,
      body: Obx(() {
        if (c.loading.value && c.card.value == null) {
          return const Center(child: CircularProgressIndicator(color: WebColors.brand));
        }
        if (c.notFound.value) {
          return WebEmptyState(
            icon: Icons.search_off,
            title: 'Card not found',
            message: 'It may have been deleted from the mobile app.',
            action: ElevatedButton(onPressed: _goHome, child: const Text('Back to cards')),
          );
        }
        final card = c.card.value;
        if (card == null) {
          return WebEmptyState(
            icon: Icons.error_outline,
            title: c.error.value ?? 'Could not load this card',
            action: ElevatedButton(onPressed: c.load, child: const Text('Try again')),
          );
        }
        return Column(
          children: [
            _Header(card: card, controller: c),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(WebSpace.page),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: WebSpace.contentMaxWidth),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 1000;
                      final info = _InfoColumn(card: card);
                      final photos = _PhotosPanel(card: card, controller: c);
                      if (!twoColumns) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [info, const SizedBox(height: WebSpace.gap), photos],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 400, child: info),
                          const SizedBox(width: WebSpace.gap),
                          Expanded(child: photos),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

void _goHome() => Get.offAllNamed('/mainCardsScreen');

void _goBack(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Get.back();
  } else {
    _goHome();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.card, required this.controller});

  final WebJobCard card;
  final WebCardDetailsController controller;

  Future<void> _toggleStatus(BuildContext context) async {
    final open = card.open;
    final ok = await webConfirm(
      context,
      title: open ? 'Mark as finished?' : 'Reopen this card?',
      message: open
          ? '${card.title} will move to Finished cards.'
          : '${card.title} will move back to New cards.',
      confirmLabel: open ? 'Mark as finished' : 'Reopen',
    );
    if (!ok || !context.mounted) return;
    final done = await controller.setOpen(!open);
    if (!context.mounted) return;
    if (done) {
      webToast(context, open ? 'Card marked as finished' : 'Card reopened');
      for (final tag in ['open', 'finished']) {
        if (Get.isRegistered<WebCardsController>(tag: tag)) {
          Get.find<WebCardsController>(tag: tag).refreshCount();
        }
      }
      if (Get.isRegistered<WebDashboardController>()) {
        Get.find<WebDashboardController>().load();
      }
    } else {
      webToast(context, controller.error.value ?? 'Could not update the card');
    }
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 760;
    final actions = <Widget>[
      OutlinedButton.icon(
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: card.shareText));
          if (context.mounted) webToast(context, 'Card details copied');
        },
        icon: const Icon(Icons.copy_outlined, size: 18),
        label: const Text('Copy'),
      ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: () => Share.share(card.shareText).catchError((_) {
          if (context.mounted) webToast(context, 'Sharing is not available in this browser');
          return ShareResult.unavailable;
        }),
        icon: const Icon(Icons.share_outlined, size: 18),
        label: const Text('Share'),
      ),
      const SizedBox(width: 8),
      Obx(
        () => ElevatedButton.icon(
          style: card.open
              ? ElevatedButton.styleFrom(backgroundColor: WebColors.green)
              : null,
          onPressed: controller.saving.value ? null : () => _toggleStatus(context),
          icon: Icon(card.open ? Icons.task_alt : Icons.undo, size: 18),
          label: Text(card.open ? 'Mark as finished' : 'Reopen card'),
        ),
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: WebSpace.page, vertical: narrow ? 12 : 14),
      decoration: const BoxDecoration(
        color: WebColors.surface,
        border: Border(bottom: BorderSide(color: WebColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _goBack(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: SelectableText(
                            card.title,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 10),
                        WebStatusChip(open: card.open, compact: true),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (card.plateNumber.isNotEmpty) 'Plate ${card.plateNumber}',
                        if (card.date.isNotEmpty) 'Received ${card.date}',
                      ].join(' · '),
                      style: const TextStyle(color: WebColors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!narrow) ...actions,
            ],
          ),
          if (narrow) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: actions),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.card});

  final WebJobCard card;

  @override
  Widget build(BuildContext context) {
    final mileage = int.tryParse(card.carMileage.replaceAll(RegExp(r'[^0-9]'), ''));
    final fuel = card.fuelAmount.clamp(0, 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WebSectionTitle('Customer'),
              const SizedBox(height: 6),
              WebInfoRow(label: 'Name', value: card.customerName, icon: Icons.person_outline),
              WebInfoRow(label: 'Phone', value: card.phoneNumber, icon: Icons.phone_outlined),
              WebInfoRow(label: 'E-mail', value: card.emailAddress, icon: Icons.mail_outline),
            ],
          ),
        ),
        const SizedBox(height: WebSpace.gap),
        WebSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WebSectionTitle('Vehicle'),
              const SizedBox(height: 6),
              WebInfoRow(label: 'Brand and model', value: card.title, icon: Icons.directions_car_outlined),
              WebInfoRow(label: 'Plate number', value: card.plateNumber, icon: Icons.pin_outlined),
              WebInfoRow(label: 'Chassis number', value: card.chassisNumber, icon: Icons.tag),
              WebInfoRow(label: 'Colour', value: card.color, icon: Icons.palette_outlined),
              WebInfoRow(label: 'Received on', value: card.date, icon: Icons.event_outlined),
            ],
          ),
        ),
        const SizedBox(height: WebSpace.gap),
        WebSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WebSectionTitle('Readings'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _Reading(
                      label: 'Mileage',
                      value: mileage == null
                          ? (card.carMileage.isEmpty ? '—' : card.carMileage)
                          : '${fmtInt(mileage)} km',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Reading(label: 'Fuel', value: '${fuel.toStringAsFixed(0)}%'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: fuel / 100,
                  minHeight: 8,
                  color: WebColors.brand,
                  backgroundColor: WebColors.bg,
                ),
              ),
            ],
          ),
        ),
        if (card.comments.isNotEmpty) ...[
          const SizedBox(height: WebSpace.gap),
          WebSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WebSectionTitle('Comments'),
                const SizedBox(height: 10),
                SelectableText(
                  card.comments,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: WebColors.text),
                ),
              ],
            ),
          ),
        ],
        if (card.customerSignature.isNotEmpty) ...[
          const SizedBox(height: WebSpace.gap),
          WebSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WebSectionTitle('Customer signature'),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.white,
                    height: 120,
                    child: CachedNetworkImage(
                      imageUrl: card.customerSignature,
                      cacheManager: JobCardImageCache.instance,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: WebColors.subtle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Reading extends StatelessWidget {
  const _Reading({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: WebColors.muted, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        SelectableText(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.1)),
      ],
    );
  }
}

class _PhotosPanel extends StatelessWidget {
  const _PhotosPanel({required this.card, required this.controller});

  final WebJobCard card;
  final WebCardDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final count = card.carImages.length;
    return WebSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WebSectionTitle(
            'Photos',
            trailing: Text(
              count == 0 ? 'None' : '$count photo${count == 1 ? '' : 's'}',
              style: const TextStyle(color: WebColors.muted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (count == 0) {
              return const WebEmptyState(
                icon: Icons.photo_library_outlined,
                title: 'No photos',
                message: 'Photos taken in the mobile app appear here, grouped by day.',
              );
            }
            if (controller.groups.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: WebColors.brand),
                      SizedBox(height: 12),
                      Text('Loading photos…', style: TextStyle(color: WebColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
              );
            }
            // Flat list in display order, so the viewer can step through all photos.
            final all = <WebPhoto>[];
            final startIndex = <String, int>{};
            for (final group in controller.groups) {
              final caption = group.key.isEmpty ? 'Other' : fmtDate(DateTime.tryParse(group.key));
              for (final img in group.value) {
                startIndex[img.imageUrl] = all.length;
                all.add(WebPhoto(img.imageUrl, caption: caption));
              }
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final group in controller.groups) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 16, color: WebColors.subtle),
                        const SizedBox(width: 6),
                        Text(
                          group.key.isEmpty ? 'Other' : fmtDate(DateTime.tryParse(group.key)),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${group.value.length}',
                          style: const TextStyle(color: WebColors.subtle, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 170,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: group.value.length,
                    itemBuilder: (context, i) => _Thumb(
                      url: group.value[i].imageUrl,
                      onTap: () => showWebPhotoViewer(
                        context,
                        photos: all,
                        initialIndex: startIndex[group.value[i].imageUrl] ?? 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.onTap});
  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: WebNetworkImage(url: url, memCacheWidth: 480),
        ),
      ),
    );
  }
}
