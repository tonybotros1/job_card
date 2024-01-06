import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/controllers/job_card_screen_controller.dart';
import 'package:signature/signature.dart';
import '../const.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:percent_indicator/percent_indicator.dart';

class JobCardScreen extends StatelessWidget {
  JobCardScreen({super.key});

  final JobCardScreenController jobCardScreenController =
      Get.put(JobCardScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: FittedBox(
          child: TextButton(
              onPressed: () {
                jobCardScreenController.clearFields();
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              )),
        ),
        centerTitle: true,
        title: const Text(
          'Work Order',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.done,
              color: Colors.white,
            ),
            onPressed: () async {
              if (jobCardScreenController.formKey.currentState!.validate()) {
                // jobCardScreenController.uploading.value = true;
                await jobCardScreenController.addCard();
              }
            },
          )
        ],
      ),
      body: Obx(() {
        if (jobCardScreenController.uploading.isTrue) {
          return StreamBuilder<TaskSnapshot>(
              stream: jobCardScreenController.videoUploadTask?.snapshotEvents,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  double progress = data!.bytesTransferred / data.totalBytes;
                  return SizedBox(
                    width: Get.width,
                    height: Get.height,
                    child: CircularPercentIndicator(
                      animation: true,
                      animationDuration: 1000,
                      radius: 180,
                      lineWidth: 30,
                      percent: progress,
                      progressColor: mainColor,
                      backgroundColor: Colors.red.shade100,
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Text(
                        '${(100 * progress).roundToDouble()} %',
                        style: TextStyle(color: mainColor, fontSize: 30),
                      ),
                    ),
                  );
                } else {
                  return SizedBox(
                    child: Center(
                        child: CircularProgressIndicator(
                      color: mainColor,
                    )),
                  );
                }
              });
        } else if (jobCardScreenController.errorWhileUploading.isTrue) {
          return Center(
              child: AlertDialog(
            title: const Text(
                'Error while uploading card informations, please try again'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    jobCardScreenController.errorWhileUploading.value = false;
                    Get.back();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    jobCardScreenController.addCard();
                  },
                  child: const Text('Try again'))
            ],
          ));
        } else {
          return SingleChildScrollView(
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: jobCardScreenController.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  myTextFormField(
                      labelText: 'Customer Name:',
                      hintText: 'Enter Customer Name here',
                      controller: jobCardScreenController.customerName,
                      validate: false),
                  dropDownValues(
                      labelText: 'Car Brand',
                      hintText: 'Enter or Search for Car Brand here',
                      list: jobCardScreenController.carBrandList,
                      selectedValue:
                          jobCardScreenController.selectedBrandValue.value,
                      controller: jobCardScreenController.carBrand,
                      validate: true),
                  dropDownValues(
                      labelText: 'Color',
                      hintText: 'Enter or Search for Car Color here',
                      list: jobCardScreenController.carColorsList,
                      selectedValue:
                          jobCardScreenController.selectedColorValue.value,
                      controller: jobCardScreenController.color,
                      validate: true),
                  myTextFormField(
                      labelText: 'Car Model:',
                      hintText: 'Enter Car Model here',
                      controller: jobCardScreenController.carModel,
                      validate: true),
                  myTextFormField(
                      labelText: 'Plate Number:',
                      hintText: 'Enter Plate Number here',
                      controller: jobCardScreenController.plateNumber,
                      validate: true),
                  myTextFormField(
                      labelText: 'Car Mileage:',
                      hintText: 'Enter Car Mileage here',
                      controller: jobCardScreenController.carMileage,
                      validate: true),
                  myTextFormField(
                      labelText: 'Chassis Number:',
                      hintText: 'Enter Chassis Number here',
                      controller: jobCardScreenController.chassisNumber,
                      validate: false),
                  myTextFormField(
                      labelText: 'Phone Number:',
                      hintText: 'Enter Phone Number here',
                      controller: jobCardScreenController.phoneNumber,
                      validate: false,
                      keyboardType: TextInputType.number),
                  myTextFormField(
                      labelText: 'Email Address:',
                      hintText: 'Enter Email Address here',
                      controller: jobCardScreenController.emailAddress,
                      validate: false,
                      keyboardType: TextInputType.emailAddress),
                  Padding(
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
                        child: const FittedBox(
                            child: Text(
                          'Select Date',
                          style: TextStyle(color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fuel:',
                          style: TextStyle(
                              color: secColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
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
                          activeColor: Colors.blue,
                          value: jobCardScreenController.fuelAmount.value,
                          onChanged: (newValue) {
                            jobCardScreenController.fuelAmount.value = newValue;
                          },
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: jobCardScreenController.fuelAmount.value
                              .round()
                              .toString(),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Text(
                          'Customer Signature:',
                          style: TextStyle(
                              color: secColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                            width: Get.width * 0.8,
                            height: Get.height * 0.4,
                            child: Signature(
                              controller: jobCardScreenController.controller,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secColor,
                            ),
                            onPressed: () {
                              jobCardScreenController.controller.clear();
                            },
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Text(
                          'Add Images/Video:',
                          style: TextStyle(
                              color: secColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
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
                                child: const Icon(Icons.camera_alt_outlined,
                                    color: Colors.white)),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: secColor),
                                onPressed: () {
                                  jobCardScreenController.recordVideo();
                                },
                                child: jobCardScreenController.recorded.isFalse
                                    ? const Icon(
                                        Icons.video_camera_back,
                                        color: Colors.white,
                                      )
                                    : const Icon(Icons.done,
                                        color: Colors.white))
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Container(
                            width: Get.width / 1.1,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                    itemCount: jobCardScreenController
                                        .imagesList.length,
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
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}

Padding myTextFormField(
    {required String labelText,
    required String hintText,
    required TextEditingController controller,
    required validate,
    keyboardType}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
    child: TextFormField(
      onTap: () {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      },
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.grey),
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2.0)),
      ),
      validator: validate != false
          ? (value) {
              if (value!.isEmpty) {
                return 'Please Enter $labelText';
              }
              return null;
            }
          : null,
    ),
  );
}

Padding dropDownValues({
  required String labelText,
  required String hintText,
  required TextEditingController controller,
  required List<String> list,
  required String selectedValue,
  required bool validate,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
    child: TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          iconColor: Colors.grey.shade700,
          suffixIcon: Icon(
            Icons.arrow_downward_rounded,
            color: Colors.grey.shade700,
          ),
          hintText: hintText,
          labelText: labelText,
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.grey.shade700),
        ),
      ),
      suggestionsCallback: (pattern) {
        return list.where(
            (item) => item.toLowerCase().contains(pattern.toLowerCase()));
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        controller.text = suggestion;
      },
      validator: validate != false
          ? (value) {
              if (value!.isEmpty) {
                return 'Please Enter $labelText';
              }
              return null;
            }
          : null,
    ),
  );
}
