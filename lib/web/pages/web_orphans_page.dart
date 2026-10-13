import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/web_orphans_controller.dart';
import '../web_images.dart';
import '../web_photo_viewer.dart';
import '../web_shell.dart';
import '../web_theme.dart';
import '../web_widgets.dart';

/// "Old data": photos left in Storage after their cards were deleted.
class WebOrphansPage extends StatelessWidget {
  const WebOrphansPage({super.key});

  Future<void> _confirmDelete(BuildContext context, WebOrphansController c) async {
    final n = c.selected.length;
    final ok = await webConfirm(
      context,
      title: 'Delete $n photo${n == 1 ? '' : 's'} from Storage?',
      message: 'They belong to no card. This cannot be undone.',
      confirmLabel: 'Delete $n',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    final done = await c.deleteSelected();
    if (context.mounted) webToast(context, 'Deleted $done photo${done == 1 ? '' : 's'}');
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WebOrphansController>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(WebSpace.page, WebSpace.page, WebSpace.page, 12),
          child: WebPageHeader(
            title: 'Old data',
            subtitle: Obx(() {
              if (c.scanning.value) return Text(c.progress.value);
              final at = c.scannedAt.value;
              if (at == null) return const Text('Photos in Storage that no card uses any more');
              return Text(
                '${fmtInt(c.totalFiles.value)} photos in Storage · ${fmtInt(c.referencedCount.value)} used by cards · '
                '${fmtInt(c.orphans.length)} without a card'
                '${c.recentCount.value > 0 ? ' · ${fmtInt(c.recentCount.value)} from the last 24 h not listed' : ''}'
                ' · scanned ${fmtDateTime(at)}',
              );
            }),
            actions: [
              Obx(() {
                final n = c.selected.length;
                if (n == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      TextButton(onPressed: c.clearSelection, child: const Text('Clear selection')),
                      const SizedBox(width: 4),
                      ElevatedButton.icon(
                        onPressed: c.deleting.value ? null : () => _confirmDelete(context, c),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: Text('Delete $n selected'),
                      ),
                    ],
                  ),
                );
              }),
              Obx(
                () => OutlinedButton.icon(
                  onPressed: c.scanning.value ? null : c.scan,
                  icon: c.scanning.value
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search, size: 18),
                  label: Text(c.scannedAt.value == null ? 'Scan Storage' : 'Scan again'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final err = c.error.value;
            if (c.scannedAt.value == null && !c.scanning.value) {
              return WebEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Find photos without a card',
                message: err ??
                    'The scan reads every file in car_pictures and every card, then lists the photos no card references. '
                        'Photos from the last 24 hours are left out in case a card is still being created. '
                        'Nothing is deleted until you select photos and confirm.',
                action: ElevatedButton.icon(
                  onPressed: c.scan,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Scan Storage'),
                ),
              );
            }
            if (c.scanning.value) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: WebColors.brand),
                    const SizedBox(height: 14),
                    Text(c.progress.value, style: const TextStyle(color: WebColors.muted)),
                  ],
                ),
              );
            }
            if (c.orphans.isEmpty) {
              return WebEmptyState(
                icon: Icons.check_circle_outline,
                title: 'No old photos',
                message: err ?? 'Every photo in Storage belongs to a card.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(WebSpace.page, 4, WebSpace.page, WebSpace.page),
              itemCount: c.groups.length + (err == null ? 0 : 1),
              itemBuilder: (context, i) {
                if (err != null && i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(err, style: const TextStyle(color: WebColors.brandDark)),
                  );
                }
                final group = c.groups[err == null ? i : i - 1];
                return _DayGroup(controller: c, dayKey: group.key, photos: group.value);
              },
            );
          }),
        ),
      ],
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.controller, required this.dayKey, required this.photos});

  final WebOrphansController controller;
  final String dayKey;
  final List<OrphanPhoto> photos;

  @override
  Widget build(BuildContext context) {
    final label = dayKey.isEmpty ? 'Unknown date' : fmtDate(DateTime.tryParse(dayKey));
    return Padding(
      padding: const EdgeInsets.only(bottom: WebSpace.gap),
      child: WebSurface(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final selectedHere = photos.where((p) => controller.selected.contains(p.path)).length;
              final all = selectedHere == photos.length;
              return Row(
                children: [
                  const Icon(Icons.event_outlined, size: 16, color: WebColors.subtle),
                  const SizedBox(width: 6),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    '${photos.length} photo${photos.length == 1 ? '' : 's'}'
                    '${selectedHere > 0 ? ' · $selectedHere selected' : ''}',
                    style: const TextStyle(color: WebColors.muted, fontSize: 12.5),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => controller.selectDay(dayKey, !all),
                    child: Text(all ? 'Unselect day' : 'Select day'),
                  ),
                ],
              );
            }),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photos.length,
              itemBuilder: (context, i) => _OrphanTile(
                controller: controller,
                photo: photos[i],
                onOpen: () => _open(context, i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, int index) async {
    // Resolve the download URLs of this day's photos, then open the viewer.
    final urls = await Future.wait(photos.map((p) => _OrphanUrls.resolve(p.path)));
    if (!context.mounted) return;
    final list = <WebPhoto>[];
    var start = 0;
    for (var i = 0; i < photos.length; i++) {
      final u = urls[i];
      if (u == null) continue;
      if (i == index) start = list.length;
      list.add(WebPhoto(u, caption: '${photos[i].name} · ${fmtDateTime(photos[i].date)}'));
    }
    await showWebPhotoViewer(context, photos: list, initialIndex: start);
  }
}

/// Download-URL cache for Storage paths (one metadata request per photo,
/// only for tiles that are actually built).
class _OrphanUrls {
  static final _cache = <String, Future<String?>>{};

  static Future<String?> resolve(String path) => _cache.putIfAbsent(path, () async {
        try {
          return await FirebaseStorage.instance.ref(path).getDownloadURL();
        } catch (_) {
          return null;
        }
      });
}

class _OrphanTile extends StatefulWidget {
  const _OrphanTile({required this.controller, required this.photo, required this.onOpen});

  final WebOrphansController controller;
  final OrphanPhoto photo;
  final VoidCallback onOpen;

  @override
  State<_OrphanTile> createState() => _OrphanTileState();
}

class _OrphanTileState extends State<_OrphanTile> {
  String? _url;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _OrphanUrls.resolve(widget.photo.path).then((u) {
      if (!mounted) return;
      setState(() {
        _url = u;
        _failed = u == null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = widget.controller.selected.contains(widget.photo.path);
      return Tooltip(
        message: '${widget.photo.name}\n${fmtDateTime(widget.photo.date)}',
        waitDuration: const Duration(milliseconds: 600),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onOpen,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _failed
                      ? Container(
                          color: WebColors.bg,
                          child: const Icon(Icons.broken_image_outlined, color: WebColors.subtle),
                        )
                      : _url == null
                          ? Container(color: WebColors.bg)
                          : WebNetworkImage(url: _url!, memCacheWidth: 400),
                ),
                if (selected)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: WebColors.brand, width: 3),
                          color: WebColors.brand.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 6,
                  top: 6,
                  child: GestureDetector(
                    onTap: () => widget.controller.toggle(widget.photo.path),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: selected ? WebColors.brand : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: selected ? WebColors.brand : WebColors.border),
                      ),
                      child: Icon(
                        selected ? Icons.check : Icons.check_box_outline_blank,
                        size: 16,
                        color: selected ? Colors.white : WebColors.subtle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                    child: Text(
                      widget.photo.date == null ? widget.photo.name : _time(widget.photo.date!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  static String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
