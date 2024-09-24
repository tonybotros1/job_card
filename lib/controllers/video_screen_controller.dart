import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  late VideoPlayerController controller;
  late Future<void> initVideoPlayerFuture;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  void init() async {
    if (Get.arguments != null) {
      var arguments = Get.arguments;
      String url = arguments.url;
      try {
        controller = VideoPlayerController.networkUrl(Uri.parse(url));
        initVideoPlayerFuture = controller.initialize();
        await initVideoPlayerFuture;
        controller.setLooping(true);
        controller.setVolume(1.0);
      } catch (e) {
        // print('Error initializing video: $e');
        // print('Stack Trace: $stackTrace');
      }
    }
    update();
  }

  void video() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    update();
  }
}
