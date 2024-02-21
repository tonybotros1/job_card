import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinishedWorksController extends GetxController {
  final RxList<DocumentSnapshot> carCards = RxList<DocumentSnapshot>([]);
  final RxList<DocumentSnapshot> filteredCarCards =
      RxList<DocumentSnapshot>([]);

  RxString userId = RxString('');

  @override
  void onInit() async {
    await getUserId();
    getFinishedWorks();
    super.onInit();
  }

// this function is to get user id:
  getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId.value = (await prefs.getString('userId'))!;
  }

// this function is to get the works from firebase
  getFinishedWorks() async {
    FirebaseFirestore.instance
        .collection('car_card')
        .where('user_id', isEqualTo: userId.value)
        .where('status', isEqualTo: false)
        // .orderBy('status', descending: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      carCards.assignAll(event.docs);
    });

    return await Future.delayed(Duration(seconds: 2));
  }

  // Function to filter the list based on search criteria
  void filterResults(String query) {
    query = query.toLowerCase();

    // Use where() to filter the list based on multiple fields
    List<DocumentSnapshot> filteredResults = carCards.where((documentSnapshot) {
      final data = documentSnapshot.data() as Map<String, dynamic>?;

      final customerName = data?['customer_name'] ?? '';
      final carBrand = data?['car_brand'] ?? '';
      final carModel = data?['car_model'] ?? '';
      final platNumber = data?['plate_number'] ?? '';
      final date = data?['date'] ?? '';

      // Check if any of the fields start with the query
      return customerName.toString().toLowerCase().contains(query) ||
          carBrand.toString().toLowerCase().contains(query) ||
          carModel.toString().toLowerCase().contains(query) ||
          platNumber.toString().toLowerCase().contains(query) ||
          date.toString().toLowerCase().contains(query);
    }).toList();

    // Update the list with the filtered results
    filteredCarCards.assignAll(filteredResults);
  }

// this function is to share the details via social media
  void shareToSocialMedia(content) {
    Share.share(content);
  }

  String shortenedUrl = '';
}
