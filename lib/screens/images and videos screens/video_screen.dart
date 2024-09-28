import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/const.dart';
import 'package:job_card/controllers/video_screen_controller.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatelessWidget {
  VideoScreen({super.key});
  final VideoController videoController = Get.put(
    VideoController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GetBuilder<VideoController>(
          init: VideoController(),
          builder: (controller) {
            return FloatingActionButton(
                backgroundColor: secColor,
                onPressed: () {
                  controller.video();
                },
                child: Icon(videoController.controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow));
          }),
      body: Center(
        child: GetBuilder<VideoController>(builder: (controller) {
          return FutureBuilder(
              future: controller.initVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: controller.controller.value.aspectRatio,
                    child: VideoPlayer(controller.controller),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              });
        }),
      ),
    );
  }
}
