import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/controllers/job_card_screen_controller.dart';
import 'package:signature/signature.dart';
import '../const.dart';

class JobCardScreen extends StatelessWidget {
  JobCardScreen({super.key});

  final JobCardScreenController jobCardScreenController =
      Get.put(JobCardScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Work Order'),
        backgroundColor: mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              if (jobCardScreenController.formKey.currentState!.validate()) {
                // Get.off(() => AllWorksScreen(),
                //     transition: Transition.leftToRight);
                Get.back();
                jobCardScreenController.addCard();
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: jobCardScreenController.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              myTextFormField(
                labelText: 'Customer Name:',
                hintText: 'Enter Customer Name here',
                controller: jobCardScreenController.customerName,
              ),
              myTextFormField(
                labelText: 'Car Brand:',
                hintText: 'Enter Car Brand here',
                controller: jobCardScreenController.carBrand,
              ),
              myTextFormField(
                labelText: 'Car Model:',
                hintText: 'Enter Car Model here',
                controller: jobCardScreenController.carModel,
              ),
              myTextFormField(
                labelText: 'Plate Number:',
                hintText: 'Enter Plate Number here',
                controller: jobCardScreenController.plateNumber,
              ),
              myTextFormField(
                labelText: 'Car Mileage:',
                hintText: 'Enter Car Mileage here',
                controller: jobCardScreenController.carMileage,
              ),
              myTextFormField(
                labelText: 'Chassis Number:',
                hintText: 'Enter Chassis Number here',
                controller: jobCardScreenController.chassisNumber,
              ),
              myTextFormField(
                labelText: 'Phone Number:',
                hintText: 'Enter Phone Number here',
                controller: jobCardScreenController.phoneNumber,
              ),
              myTextFormField(
                labelText: 'Email Address:',
                hintText: 'Enter Email Address here',
                controller: jobCardScreenController.emailAddress,
              ),
              myTextFormField(
                labelText: 'Color:',
                hintText: 'Enter Color here',
                controller: jobCardScreenController.color,
              ),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                  child: ListTile(
                    title: Text(
                      "Date: ",
                      style: fontStyle,
                    ),
                    subtitle: Text(jobCardScreenController.formatDate(
                        jobCardScreenController.selectedDate.value)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secColor,
                      ),
                      onPressed: () =>
                          jobCardScreenController.selectDateContext(context),
                      child: const FittedBox(child: Text('Select Date')),
                    ),
                  ),
                ),
              ),
              Obx(() => Column(
                    children: [
                      Container(
                        width: Get.width / 1.5,
                        color: mainColor,
                        height: 50,
                        child: const Center(
                            child: Text(
                          'Fuel',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('E'),
                            Text('H'),
                            Text('F'),
                          ],
                        ),
                      ),
                      Slider(
                        value: jobCardScreenController.fuelAmount.value,
                        onChanged: (newValue) {
                          jobCardScreenController.fuelAmount.value = newValue;
                        },
                        min: 0,
                        max: 100,
                        divisions: 4,
                        label: jobCardScreenController.fuelAmount.value
                            .round()
                            .toString(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: Get.width / 1.5,
                        color: mainColor,
                        height: 50,
                        child: const Center(
                            child: Text(
                          'Customer Signature',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        width: Get.width * 0.8,
                        height: Get.height * 0.4,
                        child: Signature(
                          controller: jobCardScreenController.controller,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secColor,
                        ),
                        onPressed: () {
                          jobCardScreenController.controller.clear();
                        },
                        child: const Text('Clear'),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Container(
                        width: Get.width / 1.5,
                        color: mainColor,
                        height: 50,
                        child: const Center(
                            child: Text(
                          'Images/Video of the car',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: secColor),
                              onPressed: () {
                                jobCardScreenController.takePhoto();
                              },
                              child: const Icon(Icons.camera_alt_outlined)),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: secColor),
                              onPressed: () {
                                jobCardScreenController.recordVideo();
                              },
                              child: jobCardScreenController.recorded.isFalse
                                  ? const Icon(Icons.video_camera_back)
                                  : const Icon(Icons.done))
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: Get.width / 1.2,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView.builder(
                                itemCount:
                                    jobCardScreenController.imagesList.length,
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemBuilder: (context, i) {
                                  if (jobCardScreenController
                                      .imagesList.isEmpty) {
                                    return const Center(
                                      child: Text('Add Photo'),
                                    );
                                  } else {
                                    return Container(
                                      margin: const EdgeInsets.all(3),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              clipBehavior: Clip.hardEdge,
                                              child: Image.file(
                                                File(jobCardScreenController
                                                    .imagesList[i].path),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                                onPressed: () {
                                                  jobCardScreenController
                                                      .imagesList
                                                      .removeAt(i);
                                                },
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red,
                                                )),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                })),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  )),
              // GetBuilder<JobCardScreenController>(
              //     init: JobCardScreenController(),
              //     builder: (controller) {
              //       return jobCardScreenController.file != null
              //           ? Column(
              //               children: [
              //                 InkWell(
              //                   onTap: jobCardScreenController.togglePlay,
              //                   child: SizedBox(
              //                     width: 200, // Adjust the size as needed
              //                     height: 150, // Adjust the size as needed
              //                     child: jobCardScreenController
              //                             .player.value.isInitialized
              //                         ? AspectRatio(
              //                             aspectRatio: jobCardScreenController
              //                                 .player.value.aspectRatio,
              //                             child: VideoPlayer(
              //                                 jobCardScreenController.player),
              //                           )
              //                         : const Center(
              //                             child:
              //                                 CircularProgressIndicator()), // You can show a loading indicator while the video is initializing.
              //                   ),
              //                 ),
              //                 ElevatedButton(
              //                     style: ElevatedButton.styleFrom(
              //                         backgroundColor: secColor),
              //                     onPressed: () {
              //                       jobCardScreenController.removeVideo();
              //                     },
              //                     child: const Text('Clear'))
              //               ],
              //             )
              //           : const SizedBox();
              //     }),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}

Padding myTextFormField(
    {required String labelText,
    required String hintText,
    required TextEditingController controller}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
    child: TextFormField(
      // initialValue: '',
      controller: controller,
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.grey),
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2.0)),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    ),
  );
}
