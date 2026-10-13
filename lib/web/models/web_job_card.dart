import 'package:cloud_firestore/cloud_firestore.dart';

/// Read-only view of a `car_card` document for the web portal.
class WebJobCard {
  final String id;
  final String customerName;
  final String carBrand;
  final String carModel;
  final String plateNumber;
  final String carMileage;
  final String chassisNumber;
  final String phoneNumber;
  final String emailAddress;
  final String color;
  final String date;
  final String comments;
  final double fuelAmount;
  final String customerSignature;
  final String carVideo;
  final List<String> carImages;
  final bool open;
  final DateTime? timestamp;

  const WebJobCard({
    required this.id,
    required this.customerName,
    required this.carBrand,
    required this.carModel,
    required this.plateNumber,
    required this.carMileage,
    required this.chassisNumber,
    required this.phoneNumber,
    required this.emailAddress,
    required this.color,
    required this.date,
    required this.comments,
    required this.fuelAmount,
    required this.customerSignature,
    required this.carVideo,
    required this.carImages,
    required this.open,
    required this.timestamp,
  });

  factory WebJobCard.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    String s(String key) => (d[key] ?? '').toString().trim();
    final fuel = d['fuel_amount'];
    final ts = d['timestamp'];
    return WebJobCard(
      id: doc.id,
      customerName: s('customer_name'),
      carBrand: s('car_brand'),
      carModel: s('car_model'),
      plateNumber: s('plate_number'),
      carMileage: s('car_mileage'),
      chassisNumber: s('chassis_number'),
      phoneNumber: s('phone_number'),
      emailAddress: s('email_address'),
      color: s('color'),
      date: s('date'),
      comments: s('comments'),
      fuelAmount: fuel is num ? fuel.toDouble() : 0,
      customerSignature: s('customer_signature'),
      carVideo: s('car_video'),
      carImages: (d['car_images'] is List)
          ? (d['car_images'] as List)
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
      open: d['status'] == true,
      timestamp: ts is Timestamp ? ts.toDate() : null,
    );
  }

  /// Brand and model on one line; stray line breaks and control characters
  /// typed into the brand field collapse to a single space.
  String get title {
    final t = '$carBrand $carModel'.replaceAll(RegExp(r'[\s\p{Cc}\p{Cf}]+', unicode: true), ' ').trim();
    return t.isEmpty ? 'Untitled card' : t;
  }

  /// Case-insensitive match on the same fields the mobile search uses.
  bool matches(String query) {
    final q = query.toLowerCase();
    return customerName.toLowerCase().contains(q) ||
        carBrand.toLowerCase().contains(q) ||
        carModel.toLowerCase().contains(q) ||
        plateNumber.toLowerCase().contains(q) ||
        date.toLowerCase().contains(q);
  }

  /// The customer message the share button has always sent.
  String get shareText =>
      'Dear $customerName,\n\nWe are pleased to inform you that we have received your car. '
      'Here are its details:\n\nBrand & Model: $carBrand, $carModel\nPlate:  $plateNumber\n'
      'Mileage: $carMileage km\nChassis No.: $chassisNumber\nColor:  $color\nReceived on: $date\n'
      'Should you have any queries, please do not hesitate to reach out. '
      'Thank you for trusting us with your vehicle.\n\nWarm regards,\nCompass Automatic Gear';
}
