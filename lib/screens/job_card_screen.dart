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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Promo Video for the car',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                color: secColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: jobCardScreenController.file == null
                                ? const Center(
                                    child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                  ))
                                : const Center(child: Text('Recorded')),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secColor,
                              ),
                              onPressed: () {
                                jobCardScreenController.recordVideo();
                              },
                              child: const Text(
                                'Record Video',
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  )),
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
