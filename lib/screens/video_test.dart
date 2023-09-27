// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:job_card/controllers/video_controller.dart';

// class VideoRecordingScreen extends StatelessWidget {
//   final VideoRecordingController controller = Get.put(VideoRecordingController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Recording'),
//       ),
//       body: FutureBuilder<void>(
//         future: controller.cameraInitialization,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return CameraPreview(controller.cameraController);
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final filePath = 'path_to_save_video.mp4'; // Provide a valid path
//           await controller.startVideoRecording(filePath);
//           // Handle video recording started
//         },
//         child: Icon(Icons.videocam),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }
