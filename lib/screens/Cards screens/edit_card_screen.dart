import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../web/web_widgets.dart';
import '../../web/web_images.dart';
import '../../mobile/form_section.dart';
import '../../mobile/upload_progress.dart';
import '../../web/web_theme.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../const.dart';
import '../../controllers/Cards Screens Controllers/edit_card_screen_controller.dart';

class EditCardScreen extends StatelessWidget {
  EditCardScreen({super.key});

  final EditCardScreenController editCardScreenController =
      Get.put(EditCardScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebColors.bg,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
        title: const Text('Work Order'),
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
                                Get.offAllNamed('/mainCardsScreen',
                                    // transition: Transition.leftToRight
                                    );
                              },
                            )
                          ],
                        ));
              },
              icon: const Icon(Icons.delete)),
          IconButton(
            icon: const Icon(Icons.done),
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
      body: GestureDetector(
        // Tapping empty space closes the keyboard.
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Obx(() {
        if (editCardScreenController.uploading.isTrue) {
          return UploadProgressView(
            stage: editCardScreenController.uploadStage.value,
            done: editCardScreenController.uploadDone.value,
            total: editCardScreenController.uploadTotal.value,
            task: editCardScreenController.addedImagesUploadTask,
          );
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
          final c = editCardScreenController;
          return Obx(
            () => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FormSection(
                  title: 'Customer',
                  icon: Icons.person_outline,
                  children: [
                    myTextFormField(
                      labelText: 'Customer name',
                      hintText: 'Enter customer name',
                      controller: c.customerName,
                    ),
                    myTextFormField(
                      labelText: 'Phone number',
                      hintText: 'Enter phone number',
                      controller: c.phoneNumber,
                    ),
                    myTextFormField(
                      labelText: 'E-mail address',
                      hintText: 'Enter e-mail address',
                      controller: c.emailAddress,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FormSection(
                  title: 'Vehicle',
                  icon: Icons.directions_car_outlined,
                  children: [
                    dropDownValues(
                        labelText: 'Car brand',
                        hintText: 'Enter or search for the brand',
                        controller: c.carBrand,
                        list: c.carBrandList,
                        selectedValue: c.selectedBrandValue.value),
                    myTextFormField(
                      labelText: 'Car model',
                      hintText: 'Enter car model',
                      controller: c.carModel,
                    ),
                    dropDownValues(
                        labelText: 'Colour',
                        hintText: 'Enter or search for the colour',
                        controller: c.color,
                        list: c.carColorsList,
                        selectedValue: c.selectedColorValue.value),
                    myTextFormField(
                      labelText: 'Plate number',
                      hintText: 'Enter plate number',
                      controller: c.plateNumber,
                    ),
                    myTextFormField(
                      labelText: 'Mileage (km)',
                      hintText: 'Enter mileage',
                      controller: c.carMileage,
                    ),
                    myTextFormField(
                      labelText: 'Chassis number',
                      hintText: 'Enter chassis number',
                      controller: c.chassisNumber,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FormSection(
                  title: 'Notes',
                  icon: Icons.notes_outlined,
                  children: [commentBox(controller: c.commentBox)],
                ),
                const SizedBox(height: 12),
                FormSection(
                  title: 'Fuel level',
                  icon: Icons.local_gas_station_outlined,
                  children: [
                    FuelSlider(
                      value: c.fuelAmount.value,
                      onChanged: (v) => c.fuelAmount.value = v,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FormSection(
                  title: 'Customer signature',
                  icon: Icons.draw_outlined,
                  trailing: TextButton.icon(
                    onPressed: () => c.controller.clear(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Clear'),
                  ),
                  children: [
                    SignaturePadField(controller: c.controller),
                    const SizedBox(height: 6),
                  ],
                ),
                const SizedBox(height: 12),
                FormSection(
                  title: 'Photos',
                  icon: Icons.photo_camera_outlined,
                  trailing: FilledButton.icon(
                    onPressed: () => c.takePhoto(),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Take photo'),
                  ),
                  children: [
                    if (c.imagesList.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text('New photos',
                            style: TextStyle(color: WebColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 6, bottom: 6),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
                        itemCount: c.imagesList.length,
                        itemBuilder: (context, i) => LocalPhotoTile(
                          image: FileImage(File(c.imagesList[i].path)),
                          onRemove: () async {
                            final ok = await webConfirm(context,
                                title: 'Remove this photo?',
                                message: 'It has not been uploaded yet.',
                                confirmLabel: 'Remove',
                                danger: true);
                            if (ok) {
                              c.imagesList.removeAt(i);
                              c.updateMethod();
                            }
                          },
                        ),
                      ),
                    ],
                    if (c.carImages.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('Saved photos (${c.carImages.length})',
                            style: const TextStyle(color: WebColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 6, bottom: 6),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
                        itemCount: c.carImages.length,
                        itemBuilder: (context, i) => Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              onTap: () => Get.toNamed('/imagesScreen'),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: WebNetworkImage(url: c.carImages[i], memCacheWidth: 400),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Material(
                                color: Colors.black54,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () async {
                                    final ok = await webConfirm(context,
                                        title: 'Delete this photo?',
                                        message: 'The photo will be removed from the card.',
                                        confirmLabel: 'Delete',
                                        danger: true);
                                    if (ok) c.removeImage(c.carImages[i]);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.delete_outline, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (c.imagesList.isEmpty && c.carImages.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: Text('No photos yet',
                              style: TextStyle(color: WebColors.muted, fontSize: 13)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await c.editValues();
                      Get.back();
                      Get.back();
                    },
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Save changes'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }
      }),
      ),
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
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextFormField(
      // initialValue: '',
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
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
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comments', style: TextStyle(fontSize: 12, color: WebColors.muted, fontWeight: FontWeight.w500)),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: WebColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 200,
          width: Get.width,
          child: TextFormField(
            controller: controller,
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              hintText: 'Type your comment here...',
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
