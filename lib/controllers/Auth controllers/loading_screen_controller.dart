import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/Cards screens/main_cards_screen.dart';

class LoadingScreenController extends GetxController {
  @override
  void onInit() async {
    // myTest();
    await checkLogStatus();
    getNotifyWhileAppOpen();
    super.onInit();
  }

  myTest() {
    FirebaseFirestore.instance.collection('car_card').get().then((value) {
      // print('==========================================');
      // var arr = [];
      // for (var element in value.docs) {
      //   if (element.data()['user_id'] != 'U9NX17IjbmQD0x27TV8x09YkoXH3') {
      //     arr.add(element.data());
      //   }
      // }
      // print(arr);
      for (var element in value.docs) {
        print(element.data()['user_id']);

        FirebaseFirestore.instance
            .collection('car_card')
            .doc(element.id)
            .update({"user_id": 'BTY5BqpEHGU5eoxbXnPCXXDo3M42'});
      }
    });

    // print(docs);
  }

// this function is to know if the user logedin on not
  checkLogStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? action = prefs.getString('deviceToken');
    if (action == null || action == '') {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => MainCardsScreen());
    }
  }

// this function to recive notificationwhile app open:
  getNotifyWhileAppOpen() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('ffffffffffffffffffffffffffffffff');
    });
  }
}
