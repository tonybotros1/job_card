import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:job_card/screens/all_works_screen.dart';
import 'package:job_card/screens/images_screen.dart';
import 'package:signature/signature.dart';
import 'package:video_player/video_player.dart';
import '../const.dart';
import '../controllers/edit_card_screen_controller.dart';

class EditCardScreen extends StatelessWidget {
  EditCardScreen({super.key});

  final EditCardScreenController editCardScreenController =
      Get.put(EditCardScreenController());

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
              onPressed: () {
                showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                          title: Text('Alert'),
                          content: Text(
                              'Are you sure you want to delete this card?'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(
                                'No',
                                style: TextStyle(color: mainColor),
                              ),
                              isDefaultAction: true,
                              onPressed: () {
                                Get.back();
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text('Yes'),
                              onPressed: () {
                                editCardScreenController.deleteCard();
                                Get.offAll(() => AllWorksScreen(),
                                    transition: Transition.leftToRight);
                              },
                            )
                          ],
                        ));
              },
              icon: const Icon(Icons.delete)),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              Get.offAll(() => AllWorksScreen(),
                  transition: Transition.leftToRight);
              editCardScreenController.editValues();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
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
                        value: editCardScreenController.fuelAmount.value,
                        onChanged: (newValue) {
                          editCardScreenController.fuelAmount.value = newValue;
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
                          width: Get.width * 0.8,
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
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
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
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                )),
            GetBuilder<EditCardScreenController>(
                init: EditCardScreenController(),
                builder: (controller) {
                  return SizedBox(
                    width: Get.width / 1.3,
                    // height: 200,
                    child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: controller.carImages.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3),
                        itemBuilder: (context, i) {
                          if (controller.carImages.isEmpty) {
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
                                              controller.carImages[i]),
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
                                                    title: Text('Alert'),
                                                    content: Text(
                                                        'Are you sure you want to delete this picture?'),
                                                    actions: [
                                                      CupertinoDialogAction(
                                                        child: Text(
                                                          'No',
                                                          style: TextStyle(
                                                              color: mainColor),
                                                        ),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                      ),
                                                      CupertinoDialogAction(
                                                        child: Text('Yes'),
                                                        onPressed: () {
                                                          controller.removeImage(
                                                              controller
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
                  );
                })
          ],
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

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

Padding dropDownValues({
  required String labelText,
  required String hintText,
  required TextEditingController controller,
  required List<String> list,
  required String selectedValue,
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
    ),
  );
}
