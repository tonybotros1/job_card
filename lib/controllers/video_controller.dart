// import 'package:get/get.dart';
// import 'package:camera/camera.dart';

// class VideoRecordingController extends GetxController {
//   late CameraController cameraController;
//   late Future<void> cameraInitialization;

//   @override
//   void onInit() {
//     super.onInit();
//     initializeCamera();
//   }

//   Future<void> initializeCamera() async {
//     final cameras = await availableCameras();
//     final camera = cameras.first;
//     cameraController = CameraController(camera, ResolutionPreset.medium);
//     cameraInitialization = cameraController.initialize();
//   }

//   Future<void> startVideoRecording(String filePath) async {
//     await cameraController.startVideoRecording();
//   }

//   Future<void> stopVideoRecording() async {
//     await cameraController.stopVideoRecording();
//   }

//   @override
//   void onClose() {
//     cameraController.dispose();
//     super.onClose();
//   }
// }
