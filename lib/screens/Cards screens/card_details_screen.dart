import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/controllers/Cards%20Screens%20Controllers/card_details_screen_controller.dart';
import 'package:job_card/models/job_card_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/image_cache.dart';
import '../../mobile/photo_gallery_screen.dart';
import '../../web/web_images.dart';
import '../../web/web_theme.dart';
import '../../web/web_widgets.dart';

/// Mobile card details, laid out like the web portal: photos, status,
/// customer, vehicle, readings, comments and signature.
class CarDetailsScreen extends StatelessWidget {
  CarDetailsScreen({super.key});

  final CardDetailsController cardDetailsController = Get.put(CardDetailsController());

  JobCardModel _model(CardDetailsController c) => JobCardModel(
        carImages: c.carImages,
        customerSignature: c.customerSignature,
        carBrand: c.carBrand,
        carMileage: c.carMileage,
        carModel: c.carModel,
        chassisNumber: c.chassisNumber,
        color: c.color,
        customerName: c.customerName,
        date: c.date,
        emailAddress: c.emailAddress,
        fuelAmount: c.fuelAmount,
        phoneNumber: c.phoneNumber,
        plateNumber: c.plateNumber,
        docID: c.id,
        comments: c.comments,
        carVideo: c.video,
        status: c.status,
      );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CardDetailsController>(
      init: cardDetailsController,
      builder: (c) {
        final title = '${c.carBrand} ${c.carModel}'.trim();
        final mileage = int.tryParse(c.carMileage.replaceAll(RegExp(r'[^0-9]'), ''));
        final fuel = c.fuelAmount.clamp(0, 100).toDouble();
        return Scaffold(
          backgroundColor: WebColors.bg,
          appBar: AppBar(
            title: Text(title.isEmpty ? 'Card' : title, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              TextButton.icon(
                onPressed: () => Get.toNamed('/editCardScreen', arguments: _model(c)),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PhotosStrip(controller: c),
              const SizedBox(height: 12),
              _ActionRow(controller: c),
              const SizedBox(height: 12),
              WebSurface(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    WebStatusChip(open: c.status),
                    const Spacer(),
                    const Text('Finished', style: TextStyle(color: WebColors.muted, fontSize: 13)),
                    const SizedBox(width: 6),
                    Switch(
                      value: !c.status,
                      onChanged: (finished) => c.changeStatus(!finished),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              WebSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WebSectionTitle('Customer'),
                    const SizedBox(height: 4),
                    WebInfoRow(label: 'Name', value: c.customerName, icon: Icons.person_outline),
                    WebInfoRow(label: 'Phone', value: c.phoneNumber, icon: Icons.phone_outlined),
                    WebInfoRow(label: 'E-mail', value: c.emailAddress, icon: Icons.mail_outline),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              WebSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WebSectionTitle('Vehicle'),
                    const SizedBox(height: 4),
                    WebInfoRow(label: 'Brand and model', value: title, icon: Icons.directions_car_outlined),
                    WebInfoRow(label: 'Plate number', value: c.plateNumber, icon: Icons.pin_outlined),
                    WebInfoRow(label: 'Chassis number', value: c.chassisNumber, icon: Icons.tag),
                    WebInfoRow(label: 'Colour', value: c.color, icon: Icons.palette_outlined),
                    WebInfoRow(label: 'Received on', value: c.date, icon: Icons.event_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              WebSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WebSectionTitle('Readings'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _Reading(
                            label: 'Mileage',
                            value: mileage == null
                                ? (c.carMileage.isEmpty ? '—' : c.carMileage)
                                : '${fmtInt(mileage)} km',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _Reading(label: 'Fuel', value: '${fuel.toStringAsFixed(0)}%')),
                      ],
                    ),
                    const SizedBox(height: 10),
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
              if (c.comments.isNotEmpty) ...[
                const SizedBox(height: 12),
                WebSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const WebSectionTitle('Comments'),
                      const SizedBox(height: 8),
                      SelectableText(c.comments, style: const TextStyle(fontSize: 14, height: 1.5)),
                    ],
                  ),
                ),
              ],
              if (c.customerSignature.isNotEmpty) ...[
                const SizedBox(height: 12),
                WebSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const WebSectionTitle('Customer signature'),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Colors.white,
                          height: 120,
                          child: CachedNetworkImage(
                            imageUrl: c.customerSignature,
                            cacheManager: JobCardImageCache.instance,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox(),
                            errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined,
                                color: WebColors.subtle),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

/// Call, WhatsApp and Share shortcuts for the customer on this card.
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.controller});

  final CardDetailsController controller;

  /// Digits only, with a UAE local prefix turned into the international form
  /// WhatsApp expects (05x… -> 9715x…).
  String? _whatsAppNumber(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '971${digits.substring(1)}';
    return digits.length >= 9 ? digits : null;
  }

  Future<void> _open(BuildContext context, Uri uri, String failure) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) webToast(context, failure);
    } catch (_) {
      if (context.mounted) webToast(context, failure);
    }
  }

  String get _shareText =>
      'Dear ${controller.customerName},\n\nWe are pleased to inform you that we have received your car. '
      'Here are its details:\n\nBrand & Model: ${controller.carBrand}, ${controller.carModel}\n'
      'Plate:  ${controller.plateNumber}\nMileage: ${controller.carMileage} km\n'
      'Chassis No.: ${controller.chassisNumber}\nColor:  ${controller.color}\nReceived on: ${controller.date}\n'
      'Should you have any queries, please do not hesitate to reach out. '
      'Thank you for trusting us with your vehicle.\n\nWarm regards,\nCompass Automatic Gear';

  @override
  Widget build(BuildContext context) {
    final phone = controller.phoneNumber.trim();
    final wa = _whatsAppNumber(phone);
    final compact = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    );
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: compact,
            onPressed: phone.isEmpty
                ? null
                : () => _open(context, Uri(scheme: 'tel', path: phone), 'No phone app available'),
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const FittedBox(child: Text('Call')),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            style: compact,
            onPressed: wa == null
                ? null
                : () => _open(
                      context,
                      Uri.parse('https://wa.me/$wa?text=${Uri.encodeComponent(_shareText)}'),
                      'WhatsApp is not available',
                    ),
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: const FittedBox(child: Text('WhatsApp')),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            style: compact,
            onPressed: () => Share.share(_shareText),
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const FittedBox(child: Text('Share')),
          ),
        ),
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
        Text(label,
            style: const TextStyle(color: WebColors.muted, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.1)),
      ],
    );
  }
}

/// Horizontal strip of the first photos; "See all" opens the full grid.
class _PhotosStrip extends StatelessWidget {
  const _PhotosStrip({required this.controller});

  final CardDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final images = controller.carImages;
    final shown = images.take(8).toList();
    return WebSurface(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WebSectionTitle(
            'Photos',
            trailing: images.isEmpty
                ? const Text('None', style: TextStyle(color: WebColors.muted, fontSize: 13))
                : TextButton(
                    onPressed: () => Get.toNamed(
                      '/cardImagesScreen',
                      arguments: JobCardModel(
                        customerName: controller.customerName,
                        carImages: controller.carImages,
                      ),
                    ),
                    child: Text('See all ${images.length}'),
                  ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: shown.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => Get.toNamed('/photoGallery',
                      arguments: PhotoGalleryArgs(urls: images, initialIndex: i)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: WebNetworkImage(url: shown[i], memCacheWidth: 360),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
