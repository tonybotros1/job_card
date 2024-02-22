import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/Cards screens/main_cards_screen.dart';

class LoadingScreenController extends GetxController {
  @override
  void onInit() async {
    await checkLogStatus();
    getNotifyWhileAppOpen();
    super.onInit();
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
