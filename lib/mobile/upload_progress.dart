import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../web/web_theme.dart';
import '../web/web_widgets.dart';

/// Saving screen shown while a card and its photos upload.
///
/// [done] / [total] count finished photos; [task] is the photo currently
/// uploading, whose byte progress fills the gap between two counts.
class UploadProgressView extends StatelessWidget {
  const UploadProgressView({
    super.key,
    required this.stage,
    required this.done,
    required this.total,
    this.task,
  });

  final String stage;
  final int done;
  final int total;
  final UploadTask? task;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WebColors.bg,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: WebSurface(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: StreamBuilder<TaskSnapshot>(
            stream: task?.snapshotEvents,
            builder: (context, snapshot) {
              double current = 0;
              final data = snapshot.data;
              if (data != null && data.totalBytes > 0) {
                current = data.bytesTransferred / data.totalBytes;
              }
              final double? overall = total > 0 ? ((done + current) / total).clamp(0.0, 1.0) : null;
              final percent = overall == null ? null : (overall * 100).round();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo2.png', height: 56),
                  const SizedBox(height: 20),
                  const Text(
                    'Saving the card',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.isEmpty ? 'Please keep the app open' : stage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: WebColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: overall,
                      minHeight: 8,
                      color: WebColors.brand,
                      backgroundColor: WebColors.bg,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    total > 0
                        ? 'Photo ${(done + 1).clamp(1, total)} of $total · $percent%'
                        : 'Uploading…',
                    style: const TextStyle(color: WebColors.subtle, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
