import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/card_navigation.dart';
import '../../common/messenger.dart';

class LoadingScreenController extends GetxController {
  @override
  void onInit() async {
    // await myTest();
    getNotifyWhileAppOpen();
    await checkLogStatus();
    super.onInit();
  }

  // myTest() {
  //   FirebaseFirestore.instance.collection('car_card').get().then((value) {
      
  //     // for (var element in value.docs) {
  //     //   print(element.data()['user_id']);

  //     //   FirebaseFirestore.instance
  //     //       .collection('car_card')
  //     //       .doc(element.id)
  //     //       .update({"user_id": 'BTY5BqpEHGU5eoxbXnPCXXDo3M42'});
  //     // }
  //     for (var element in value.docs) {
  //       print(element.data()['comments']);

  //       FirebaseFirestore.instance
  //           .collection('car_card')
  //           .doc(element.id)
  //           .update({"comments": ''});
  //     }
  //   });

  //   // print(docs);
  // }

// this function is to know if the user logedin on not
  checkLogStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? action = prefs.getString('deviceToken');
    if (action == null || action == '') {
      Get.offAllNamed('/loginScreen');
    } else {
      Get.offAllNamed('/mainCardsScreen');
      // App launched from a notification while it was closed: open its card
      // on top of the main screen.
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      final id = initial == null ? null : cardIdFromMessage(initial);
      if (id != null) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        await openCardById(id);
      }
    }
  }

// this function to recive notificationwhile app open:
  getNotifyWhileAppOpen() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // The system shows nothing while the app is open: show a banner instead.
      final n = message.notification;
      if (n == null) return;
      final id = cardIdFromMessage(message);
      showAppBanner(
        n.title ?? 'Job Card',
        n.body ?? '',
        onOpen: id == null ? null : () => openCardById(id),
      );
    });

    // Tapping a notification while the app is in the background.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final id = cardIdFromMessage(message);
      if (id != null) openCardById(id);
    });
  }
}
