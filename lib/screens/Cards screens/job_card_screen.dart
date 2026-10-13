import 'dart:io';

import 'package:flutter/material.dart';
import '../../mobile/form_section.dart';
import '../../mobile/upload_progress.dart';
import '../../web/web_theme.dart';
import 'package:get/get.dart';
import 'package:job_card/controllers/Cards%20Screens%20Controllers/job_card_screen_controller.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class JobCardScreen extends StatelessWidget {
  JobCardScreen({super.key});

  final JobCardScreenController jobCardScreenController =
      Get.put(JobCardScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebColors.bg,
      appBar: AppBar(
        leading: FittedBox(
          child: TextButton(
              onPressed: () {
                jobCardScreenController.clearFields();
              },
              child: const Text('Clear')),
        ),
        centerTitle: true,
        title: const Text('Work Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              if (jobCardScreenController.formKey.currentState!.validate()) {
                // jobCardScreenController.uploading.value = true;
                await jobCardScreenController.addCard();
              }
            },
          )
        ],
      ),
      body: GestureDetector(
        // Tapping empty space closes the keyboard.
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Obx(() {
        if (jobCardScreenController.uploading.isTrue) {
          return UploadProgressView(
            stage: jobCardScreenController.uploadStage.value,
            done: jobCardScreenController.uploadDone.value,
            total: jobCardScreenController.uploadTotal.value,
            task: jobCardScreenController.addedImagesUploadTask,
          );
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
          final c = jobCardScreenController;
          return Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: c.formKey,
            child: ListView(
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
                        validate: false),
                    myTextFormField(
                        labelText: 'Phone number',
                        hintText: 'Enter phone number',
                        controller: c.phoneNumber,
                        validate: false,
                        keyboardType: TextInputType.phone),
                    myTextFormField(
                        labelText: 'E-mail address',
                        hintText: 'Enter e-mail address',
                        controller: c.emailAddress,
                        validate: false,
                        keyboardType: TextInputType.emailAddress),
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
                        list: c.carBrandList,
                        selectedValue: c.selectedBrandValue.value,
                        controller: c.carBrand,
                        validate: true),
                    myTextFormField(
                        labelText: 'Car model',
                        hintText: 'Enter car model',
                        controller: c.carModel,
                        validate: true),
                    dropDownValues(
                        labelText: 'Colour',
                        hintText: 'Enter or search for the colour',
                        list: c.carColorsList,
                        selectedValue: c.selectedColorValue.value,
                        controller: c.color,
                        validate: true),
                    myTextFormField(
                        labelText: 'Plate number',
                        hintText: 'Enter plate number',
                        controller: c.plateNumber,
                        validate: true),
                    myTextFormField(
                        labelText: 'Mileage (km)',
                        hintText: 'Enter mileage',
                        controller: c.carMileage,
                        validate: true,
                        keyboardType: TextInputType.number),
                    myTextFormField(
                        labelText: 'Chassis number',
                        hintText: 'Enter chassis number',
                        controller: c.chassisNumber,
                        validate: false),
                  ],
                ),
                const SizedBox(height: 12),
                FormSection(
                  title: 'Received on',
                  icon: Icons.event_outlined,
                  trailing: OutlinedButton.icon(
                    onPressed: () => c.selectDateContext(context),
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: const Text('Change'),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        c.formatDate(c.selectedDate.value),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    commentBox(controller: c.commentBox),
                  ],
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
                    if (c.imagesList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: Text('No photos yet',
                              style: TextStyle(color: WebColors.muted, fontSize: 13)),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 6, bottom: 6),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
                        itemCount: c.imagesList.length,
                        itemBuilder: (context, i) => LocalPhotoTile(
                          image: FileImage(File(c.imagesList[i].path)),
                          onRemove: () => c.imagesList.removeAt(i),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (c.formKey.currentState!.validate()) {
                        await c.addCard();
                      }
                    },
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Save card'),
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


Padding myTextFormField(
    {required String labelText,
    required String hintText,
    required TextEditingController controller,
    required validate,
    keyboardType}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
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
        labelText: labelText,
        hintText: hintText,
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
  required bool validate,
}) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TypeAheadField(
        controller: controller,
        // Instead of textFieldConfiguration, we use the builder to return a TextField
        builder: (context, textEditingController, focusNode) => TextField(
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
        ),
        suggestionsCallback: (pattern) async {
          return list
              .where((item) =>
                  item.toString().toLowerCase().contains(pattern.toLowerCase()))
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
        errorBuilder: (context, error) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        emptyBuilder: (context) => const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No items found'),
        ),
        debounceDuration: const Duration(milliseconds: 300),
        direction: VerticalDirection.down,
        hideOnEmpty: true,
        animationDuration: const Duration(milliseconds: 200),
        hideOnSelect: true,
        hideKeyboardOnDrag: true,

        // suggestionsController: SuggestionsController(),
        transitionBuilder: (context, animation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ));
}
