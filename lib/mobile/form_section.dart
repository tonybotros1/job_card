import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../web/web_theme.dart';
import '../web/web_widgets.dart';

/// Signature area inside a scrolling form. The preview is read-only (so the
/// page keeps scrolling normally); tapping it opens a full-screen pad where
/// every drag is a pen stroke.
class SignaturePadField extends StatelessWidget {
  const SignaturePadField({super.key, required this.controller});

  final SignatureController controller;

  Future<void> _openPad(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => SignaturePadPage(controller: controller),
      ),
    );
  }

  /// Logical canvas the signature is drawn on; the preview scales it down so
  /// strokes land in the same place on both.
  static const canvasWidth = 900.0;
  static const canvasHeight = 540.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPad(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: WebColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: canvasWidth / canvasHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: canvasWidth,
                  height: canvasHeight,
                  child: IgnorePointer(
                    child: Signature(
                      controller: controller,
                      width: canvasWidth,
                      height: canvasHeight,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final empty = controller.isEmpty;
                return Align(
                  alignment: empty ? Alignment.center : Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: empty
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.draw_outlined, color: WebColors.subtle, size: 28),
                              const SizedBox(height: 8),
                              const Text('Tap to sign',
                                  style: TextStyle(color: WebColors.muted, fontSize: 13)),
                            ],
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: WebColors.bg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: WebColors.border),
                            ),
                            child: const Text('Tap to edit',
                                style: TextStyle(color: WebColors.muted, fontSize: 12)),
                          ),
                  ),
                );
              },
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen signing page: nothing scrolls here, so drawing is reliable.
class SignaturePadPage extends StatelessWidget {
  const SignaturePadPage({super.key, required this.controller});

  final SignatureController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebColors.bg,
      appBar: AppBar(
        title: const Text('Customer signature'),
        actions: [
          TextButton.icon(
            onPressed: controller.clear,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Clear'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Ask the customer to sign with a finger.',
              style: TextStyle(color: WebColors.muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Center(
                // Same logical canvas as the preview, scaled to fit the screen.
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    width: SignaturePadField.canvasWidth,
                    height: SignaturePadField.canvasHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: WebColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Signature(
                      controller: controller,
                      width: SignaturePadField.canvasWidth,
                      height: SignaturePadField.canvasHeight,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Done'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Titled white panel that groups related form fields on the phone.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return WebSurface(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: WebColors.muted),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

/// Thumbnail of a photo picked on the phone, with a remove button.
class LocalPhotoTile extends StatelessWidget {
  const LocalPhotoTile({super.key, required this.image, required this.onRemove});

  final ImageProvider image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image(image: image, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fuel gauge input: E / H / F labels, slider and the value.
class FuelSlider extends StatelessWidget {
  const FuelSlider({super.key, required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: WebColors.muted, fontSize: 12, fontWeight: FontWeight.w600);
    return Column(
      children: [
        Row(
          children: [
            const Text('E', style: labelStyle),
            const Spacer(),
            const Text('H', style: labelStyle),
            const Spacer(),
            const Text('F', style: labelStyle),
            const SizedBox(width: 12),
            Text('${value.round()}%',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${value.round()}%',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
