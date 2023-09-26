import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AllWorksController extends GetxController {
  final RxList<DocumentSnapshot> carCards = RxList<DocumentSnapshot>([]);

  @override
  void onInit() {
    getAllWorks();
    super.onInit();
  }

// this function is to get the works from firebase
  void getAllWorks() {
    FirebaseFirestore.instance
        .collection('car_card').orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      carCards.assignAll(event.docs);
    });
    // print(carCards);
  }
}
