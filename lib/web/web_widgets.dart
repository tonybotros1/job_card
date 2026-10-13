import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'web_theme.dart';

String fmtDate(DateTime? d) => d == null ? '' : DateFormat('d MMM yyyy').format(d);
String fmtDateTime(DateTime? d) =>
    d == null ? '' : DateFormat('d MMM yyyy, HH:mm').format(d);
String fmtInt(num n) => NumberFormat.decimalPattern().format(n);

/// White panel with a hairline border - the basic building block of every page.
class WebSurface extends StatelessWidget {
  const WebSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: WebColors.surface,
        borderRadius: BorderRadius.circular(WebSpace.radius),
        border: Border.all(color: WebColors.border),
      ),
      child: child,
    );
  }
}

/// Section heading inside a surface, with an optional trailing widget.
class WebSectionTitle extends StatelessWidget {
  const WebSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// "New" / "Finished" pill.
class WebStatusChip extends StatelessWidget {
  const WebStatusChip({super.key, required this.open, this.compact = false});

  final bool open;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = open ? WebColors.brand : WebColors.green;
    final tint = open ? WebColors.brandTint : WebColors.greenTint;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            open ? 'New' : 'Finished',
            style: TextStyle(
              color: color,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard statistic.
class WebStatTile extends StatelessWidget {
  const WebStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.tint,
    this.onTap,
  });

  final String label;
  final int? value;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return WebHoverCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: WebColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  value == null
                      ? const _Skeleton(width: 64, height: 24)
                      : Text(
                          fmtInt(value!),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Surface that lifts slightly on hover and is clickable.
class WebHoverCard extends StatefulWidget {
  const WebHoverCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<WebHoverCard> createState() => _WebHoverCardState();
}

class _WebHoverCardState extends State<WebHoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final clickable = widget.onTap != null;
    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: WebColors.surface,
          borderRadius: BorderRadius.circular(WebSpace.radius),
          border: Border.all(
            color: _hover && clickable ? WebColors.subtle : WebColors.border,
          ),
          boxShadow: _hover && clickable
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(WebSpace.radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: widget.onTap, child: widget.child),
        ),
      ),
    );
  }
}

/// Search box used in the page headers.
class WebSearchField extends StatelessWidget {
  const WebSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            prefixIcon: const Icon(Icons.search, size: 20, color: WebColors.subtle),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                  ),
          ),
        );
      },
    );
  }
}

/// Label above a selectable value, for the details page.
class WebInfoRow extends StatelessWidget {
  const WebInfoRow({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: WebColors.subtle),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: WebColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(
                    fontSize: 14,
                    color: value.isEmpty ? WebColors.subtle : WebColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WebEmptyState extends StatelessWidget {
  const WebEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: WebColors.bg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: WebColors.subtle, size: 26),
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: WebColors.muted, fontSize: 13),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: WebColors.bg,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class WebSkeletonLine extends StatelessWidget {
  const WebSkeletonLine({super.key, this.width = 120, this.height = 14});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => _Skeleton(width: width, height: height);
}

/// Styled confirmation dialog. Returns true when the user confirms.
Future<bool> webConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: danger
              ? null
              : ElevatedButton.styleFrom(backgroundColor: WebColors.text),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void webToast(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
