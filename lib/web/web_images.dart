import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../common/image_cache.dart';
import 'web_theme.dart';

/// Thumbnail lookup for photos stored in Firebase Storage.
///
/// Storage cannot resize on request, so the portal looks for a pre-made
/// thumbnail next to each original, named the way the Firebase "Resize Images"
/// extension writes them:
///   `car_pictures/1791875661752.jpg`
///   -> `car_pictures/thumbnails/1791875661752_600x600.jpg`
/// Extension settings that match: sizes `600x600`, resized images path
/// `thumbnails`, keep the original format. Until the thumbnails exist every
/// lookup fails, so after [_maxMisses] misses in a row lookups are skipped for
/// the rest of the session and the originals are shown.
class WebThumbnails {
  static const folder = 'thumbnails';
  static const size = '600x600';
  static const _maxMisses = 6;

  static final _cache = <String, Future<String?>>{};
  static int _misses = 0;
  static bool _disabled = false;
  static Future<String?>? _probe;

  /// Thumbnail download URL for [originalUrl], or null when there is none.
  ///
  /// The very first lookup acts as a probe: every other lookup waits for it, so
  /// a bucket without thumbnails costs one failed request, not one per picture.
  static Future<String?> lookup(String originalUrl) {
    if (_disabled) return Future.value(null);
    return _cache.putIfAbsent(originalUrl, () async {
      if (_probe == null) {
        _probe = _resolve(originalUrl);
        return _probe!;
      }
      await _probe;
      if (_disabled) return null;
      return _resolve(originalUrl);
    });
  }

  static Future<String?> _resolve(String originalUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(originalUrl);
      final name = ref.name;
      final dot = name.lastIndexOf('.');
      final base = dot > 0 ? name.substring(0, dot) : name;
      final ext = dot > 0 ? name.substring(dot) : '';
      final dir = ref.parent?.fullPath ?? '';
      final thumbPath = '${dir.isEmpty ? '' : '$dir/'}$folder/${base}_$size$ext';
      final url = await FirebaseStorage.instance.ref(thumbPath).getDownloadURL();
      _misses = 0;
      return url;
    } catch (_) {
      if (++_misses >= _maxMisses) _disabled = true;
      return null;
    }
  }
}

/// Lets only a few pictures download at once so the first visible ones arrive
/// quickly instead of every picture on the page sharing the bandwidth.
class WebImageQueue {
  static const maxConcurrent = 3;
  static int _active = 0;
  static final _waiting = <Completer<void>>[];

  static Future<void> acquire(Completer<void> ticket) {
    if (_active < maxConcurrent) {
      _active++;
      ticket.complete();
    } else {
      _waiting.add(ticket);
    }
    return ticket.future;
  }

  /// Called once per granted slot when the download ends or the widget goes away.
  static void release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeAt(0).complete();
    } else if (_active > 0) {
      _active--;
    }
  }

  /// Drops a ticket that is still waiting (the widget was disposed).
  static bool cancel(Completer<void> ticket) => _waiting.remove(ticket);
}

/// Network image that goes through [WebThumbnails] and [WebImageQueue].
class WebNetworkImage extends StatefulWidget {
  const WebNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.useThumbnail = true,
    this.placeholder,
  });

  final String url;
  final BoxFit fit;
  final int? memCacheWidth;
  final bool useThumbnail;
  final Widget? placeholder;

  @override
  State<WebNetworkImage> createState() => _WebNetworkImageState();
}

class _WebNetworkImageState extends State<WebNetworkImage> {
  final _ticket = Completer<void>();
  String? _url;
  bool _granted = false;
  bool _released = false;
  bool _triedThumbnail = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    String url = widget.url;
    if (widget.useThumbnail) {
      final thumb = await WebThumbnails.lookup(widget.url);
      if (!mounted) return;
      if (thumb != null) {
        url = thumb;
        _triedThumbnail = true;
      }
    }
    await WebImageQueue.acquire(_ticket);
    if (!mounted) {
      _release();
      return;
    }
    setState(() {
      _url = url;
      _granted = true;
    });
  }

  void _release() {
    if (_released) return;
    _released = true;
    if (_granted || _ticket.isCompleted) {
      WebImageQueue.release();
    } else {
      WebImageQueue.cancel(_ticket);
    }
  }

  @override
  void dispose() {
    if (_granted) {
      // Slot granted but the picture may still be loading: free it anyway so
      // a scrolled-away tile cannot block the visible ones.
      _release();
    } else {
      _released = true;
      WebImageQueue.cancel(_ticket);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.placeholder ?? const ColoredBox(color: WebColors.bg);
    final url = _url;
    if (!_granted || url == null) return placeholder;
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: JobCardImageCache.instance,
      fit: widget.fit,
      memCacheWidth: widget.memCacheWidth,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => placeholder,
      imageBuilder: (_, provider) {
        _release();
        return Image(image: provider, fit: widget.fit);
      },
      errorWidget: (_, __, ___) {
        _release();
        if (_triedThumbnail && url != widget.url) {
          // Thumbnail missing or unreadable: fall back to the original once.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // The queue slot was released above; the retry loads unqueued.
              setState(() {
                _triedThumbnail = false;
                _url = widget.url;
              });
            }
          });
          return placeholder;
        }
        return Container(
          color: WebColors.bg,
          child: const Icon(Icons.broken_image_outlined, color: WebColors.subtle),
        );
      },
    );
  }
}
