import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'web_images.dart';
import 'web_theme.dart';

/// A photo to show in the viewer: the full-size URL and an optional caption
/// (e.g. the day it was taken).
class WebPhoto {
  const WebPhoto(this.url, {this.caption});
  final String url;
  final String? caption;
}

/// Full-screen viewer with keyboard and on-screen arrows.
///
/// Left / Right (and A / D) move between photos, R / L rotate the picture a
/// quarter turn, Escape closes, the mouse wheel and pinch zoom the picture.
Future<void> showWebPhotoViewer(
  BuildContext context, {
  required List<WebPhoto> photos,
  int initialIndex = 0,
}) {
  if (photos.isEmpty) return Future.value();
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    useSafeArea: false,
    builder: (_) => _PhotoViewer(photos: photos, initialIndex: initialIndex.clamp(0, photos.length - 1)),
  );
}

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({required this.photos, required this.initialIndex});

  final List<WebPhoto> photos;
  final int initialIndex;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late int _index = widget.initialIndex;
  final _focus = FocusNode();
  final _zoom = TransformationController();

  /// Quarter turns clockwise applied to the current photo (0..3).
  int _turns = 0;

  bool get _hasPrev => _index > 0;
  bool get _hasNext => _index < widget.photos.length - 1;

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.photos.length) return;
    setState(() {
      _index = next;
      _turns = 0;
      _zoom.value = Matrix4.identity();
    });
  }

  /// Rotates the picture by [delta] quarter turns (positive = clockwise).
  void _rotate(int delta) {
    setState(() {
      _turns = (_turns + delta) % 4;
      _zoom.value = Matrix4.identity();
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      _go(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      _go(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyR) {
      _rotate(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyL) {
      _rotate(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focus.dispose();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_index];
    final total = widget.photos.length;
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Click outside the picture closes the viewer.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(72, 64, 72, 48),
                child: GestureDetector(
                  onTap: () {},
                  onDoubleTap: () => setState(() => _zoom.value = Matrix4.identity()),
                  child: InteractiveViewer(
                    transformationController: _zoom,
                    minScale: 1,
                    maxScale: 5,
                    child: RotatedBox(
                      quarterTurns: _turns,
                      child: WebNetworkImage(
                        key: ValueKey(photo.url),
                        url: photo.url,
                        useThumbnail: false,
                        fit: BoxFit.contain,
                        placeholder: const Center(
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Top bar: counter, caption, close.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      '${_index + 1} / $total',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    if (photo.caption != null && photo.caption!.isNotEmpty) ...[
                      const SizedBox(width: 14),
                      Text(photo.caption!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                    const Spacer(),
                    const Text('← →  to browse   R / L to rotate   Esc to close',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Rotate left (L)',
                      color: Colors.white,
                      icon: const Icon(Icons.rotate_left),
                      onPressed: () => _rotate(-1),
                    ),
                    IconButton(
                      tooltip: 'Rotate right (R)',
                      color: Colors.white,
                      icon: const Icon(Icons.rotate_right),
                      onPressed: () => _rotate(1),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Close (Esc)',
                      color: Colors.white,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            if (_hasPrev)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(child: _ArrowButton(icon: Icons.chevron_left, tooltip: 'Previous (←)', onTap: () => _go(-1))),
              ),
            if (_hasNext)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(child: _ArrowButton(icon: Icons.chevron_right, tooltip: 'Next (→)', onTap: () => _go(1))),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: WebColors.brand.withValues(alpha: 0.6),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
