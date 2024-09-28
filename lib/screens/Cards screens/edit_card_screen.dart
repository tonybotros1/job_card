import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:job_card/screens/images%20and%20videos%20screens/images_screen.dart';
import 'package:job_card/screens/Cards%20screens/main_cards_screen.dart';
import 'package:signature/signature.dart';
import 'package:video_player/video_player.dart';
import '../../const.dart';
import '../../controllers/Cards Screens Controllers/edit_card_screen_controller.dart';
import 'package:percent_indicator/percent_indicator.dart';

class EditCardScreen extends StatelessWidget {
  EditCardScreen({super.key});

  final EditCardScreenController editCardScreenController =
      Get.put(EditCardScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        centerTitle: true,
        title: const Text(
          'Work Order',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        actions: [
          IconButton(
              onPressed: () {
                showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                          title: const Text('Alert'),
                          content: const Text(
                              'Are you sure you want to delete this card?'),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Get.back();
                              },
                              child: Text(
                                'No',
                                style: TextStyle(color: mainColor),
                              ),
                            ),
                            CupertinoDialogAction(
                              child: const Text('Yes'),
                              onPressed: () {
                                editCardScreenController.deleteCard();
                                Get.offAll(() => const MainCardsScreen(),
                                    transition: Transition.leftToRight);
                              },
                            )
                          ],
                        ));
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              )),
          IconButton(
            icon: const Icon(
              Icons.done,
              color: Colors.white,
            ),
            onPressed: () async {
              // Get.offAll(() => AllWorksScreen(),
              //     transition: Transition.leftToRight);
              await editCardScreenController.editValues();
              Get.back();
              Get.back();
            },
          )
        ],
      ),
      body: Obx(() {
        if (editCardScreenController.uploading.isTrue) {
          return StreamBuilder<TaskSnapshot>(
              stream: editCardScreenController
                  .addedImagesUploadTask?.snapshotEvents,
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
                      radius: 150,
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
          // return Center(
          //   child: CircularProgressIndicator(),
          // );
        } else if (editCardScreenController.errorWhileUploading.isTrue) {
          return Center(
              child: AlertDialog(
            title: const Text(
                'Error while uploading card informations, please try again'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    editCardScreenController.errorWhileUploading.value = false;
                    Get.back();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    editCardScreenController.editValues();
                  },
                  child: const Text('Try again'))
            ],
          ));
        } else {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myTextFormField(
                  labelText: 'Customer Name:',
                  hintText: 'Enter Customer Name here',
                  controller: editCardScreenController.customerName,
                ),
                dropDownValues(
                    labelText: 'Car Brand',
                    hintText: 'Enter Car Brand here',
                    controller: editCardScreenController.carBrand,
                    list: editCardScreenController.carBrandList,
                    selectedValue:
                        editCardScreenController.selectedBrandValue.value),
                dropDownValues(
                    labelText: 'Color',
                    hintText: 'Enter Color here',
                    controller: editCardScreenController.color,
                    list: editCardScreenController.carColorsList,
                    selectedValue:
                        editCardScreenController.selectedColorValue.value),
                myTextFormField(
                  labelText: 'Car Model:',
                  hintText: 'Enter Car Model here',
                  controller: editCardScreenController.carModel,
                ),
                myTextFormField(
                  labelText: 'Plate Number:',
                  hintText: 'Enter Plate Number here',
                  controller: editCardScreenController.plateNumber,
                ),
                myTextFormField(
                  labelText: 'Car Mileage:',
                  hintText: 'Enter Car Mileage here',
                  controller: editCardScreenController.carMileage,
                ),
                myTextFormField(
                  labelText: 'Chassis Number:',
                  hintText: 'Enter Chassis Number here',
                  controller: editCardScreenController.chassisNumber,
                ),
                myTextFormField(
                  labelText: 'Phone Number:',
                  hintText: 'Enter Phone Number here',
                  controller: editCardScreenController.phoneNumber,
                ),
                myTextFormField(
                  labelText: 'Email Address:',
                  hintText: 'Enter Email Address here',
                  controller: editCardScreenController.emailAddress,
                ),
                commentBox(controller: editCardScreenController.commentBox),
                const SizedBox(
                  height: 20,
                ),
                Obx(() => Padding(
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
                            value: editCardScreenController.fuelAmount.value,
                            onChanged: (newValue) {
                              editCardScreenController.fuelAmount.value =
                                  newValue;
                            },
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: editCardScreenController.fuelAmount.value
                                .round()
                                .toString(),
                          ),
                          const SizedBox(
                            height: 50,
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
                              width: Get.width * 0.9,
                              height: Get.height * 0.4,
                              child: Signature(
                                controller: editCardScreenController.controller,
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
                                editCardScreenController.controller.clear();
                              },
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              editCardScreenController.carImages.isNotEmpty
                                  ? Text(
                                      'Images of the car',
                                      style: TextStyle(
                                          color: secColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : const SizedBox(
                                      height: 30,
                                    ),
                              ElevatedButton(
                                  onPressed: () {
                                    editCardScreenController.takePhoto();
                                  },
                                  child: Text(
                                    'New Image',
                                    style: TextStyle(color: secColor),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    )),
                Container(
                  width: Get.width / 1.1,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: GridView.builder(
                      itemCount: editCardScreenController.imagesList.length,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemBuilder: (context, i) {
                        if (editCardScreenController.imagesList.isEmpty) {
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
                                  borderRadius: BorderRadius.circular(20),
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.file(
                                      File(editCardScreenController
                                          .imagesList[i].path),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                      onPressed: () {
                                        // controller.imagesList.removeAt(i);
                                        // controller.updateMethod();
                                        showCupertinoDialog(
                                            context: context,
                                            builder: (context) =>
                                                CupertinoAlertDialog(
                                                  title: const Text('Alert'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this picture?'),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                      isDefaultAction: true,
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      child: Text(
                                                        'No',
                                                        style: TextStyle(
                                                            color: mainColor),
                                                      ),
                                                    ),
                                                    CupertinoDialogAction(
                                                      child: const Text('Yes'),
                                                      onPressed: () {
                                                        editCardScreenController
                                                            .imagesList
                                                            .removeAt(i);
                                                        editCardScreenController
                                                            .updateMethod();
                                                        Get.back();
                                                      },
                                                    )
                                                  ],
                                                ));
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
                      }),
                ),
                SizedBox(
                  width: Get.width / 1.1,
                  // height: 200,
                  child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: editCardScreenController.carImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemBuilder: (context, i) {
                        if (editCardScreenController.carImages.isEmpty) {
                          return const SizedBox(
                            height: 100,
                          );
                        } else {
                          return Container(
                            margin: const EdgeInsets.all(3),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: FittedBox(
                                      fit: BoxFit.cover,
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        onTap: () =>
                                            Get.to(() => ImagesScreen()),
                                        child: Image.network(
                                            editCardScreenController
                                                .carImages[i]),
                                      )),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                      onPressed: () {
                                        showCupertinoDialog(
                                            context: context,
                                            builder: (context) =>
                                                CupertinoAlertDialog(
                                                  title: const Text('Alert'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this picture?'),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                      isDefaultAction: true,
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      child: Text(
                                                        'No',
                                                        style: TextStyle(
                                                            color: mainColor),
                                                      ),
                                                    ),
                                                    CupertinoDialogAction(
                                                      child: const Text('Yes'),
                                                      onPressed: () {
                                                        editCardScreenController
                                                            .removeImage(
                                                                editCardScreenController
                                                                    .carImages[i]);
                                                        Get.back();
                                                      },
                                                    )
                                                  ],
                                                ));
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
                      }),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}

class ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const ControlsOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

Padding myTextFormField(
    {required labelText, required hintText, required controller}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 5, 30, 5), // Adjust padding
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

Padding commentBox({
  required TextEditingController controller,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 15, 30, 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Comments:',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700),
          ),
          height: 200,
          width: Get.width,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10),
              hintText: 'Type your comment here...',
            ),
            onTap: () {
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            },
            onChanged: (value) {
              controller.text = value;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            },
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ],
    ),
  );
}

Padding dropDownValues({
  required String labelText,
  required String hintText,
  required TextEditingController controller,
  required List<String> list,
  required String selectedValue,
}) {
  return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
      child: TypeAheadField(
        controller: controller,
        builder: (context, textEditingController, focusNode) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
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
          );
        },
        suggestionsCallback: (pattern) async {
          return list
              .where(
                  (item) => item.toLowerCase().contains(pattern.toLowerCase()))
              .toList();
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion.toString()),
          );
        },
        onSelected: (suggestion) {
          controller.text = suggestion.toString();
        },
        emptyBuilder: (context) => const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No items found'),
        ),
      ));
}
