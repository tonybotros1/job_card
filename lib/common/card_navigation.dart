import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../models/job_card_model.dart';
import '../screens/Cards screens/card_details_screen.dart';
import '../web/models/web_job_card.dart';
import 'messenger.dart';

/// Opens the phone's card page for [card].
void openCardDetails(WebJobCard card) {
  Get.to(
    () => CarDetailsScreen(),
    arguments: JobCardModel(
      carImages: card.carImages,
      customerSignature: card.customerSignature,
      carBrand: card.carBrand,
      carMileage: card.carMileage,
      carModel: card.carModel,
      chassisNumber: card.chassisNumber,
      color: card.color,
      customerName: card.customerName,
      date: card.date,
      emailAddress: card.emailAddress,
      fuelAmount: card.fuelAmount,
      phoneNumber: card.phoneNumber,
      plateNumber: card.plateNumber,
      comments: card.comments,
      docID: card.id,
      carVideo: card.carVideo,
      status: card.open,
    ),
    transition: Transition.rightToLeft,
    preventDuplicates: false,
  );
}

/// Loads a card by id and opens it; tells the user when it no longer exists.
Future<void> openCardById(String id) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('car_card').doc(id).get();
    if (!doc.exists) {
      showAppBanner('Card not found', 'It may have been deleted.');
      return;
    }
    openCardDetails(WebJobCard.fromDoc(doc));
  } catch (_) {
    showAppBanner('Could not open the card', 'Please try again.');
  }
}

/// Card id carried by a "new card" push notification, if any.
String? cardIdFromMessage(RemoteMessage message) {
  final id = message.data['cardId'];
  return id is String && id.isNotEmpty ? id : null;
}
