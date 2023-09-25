import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/controllers/job_card_screen_controller.dart';
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
              jobCardScreenController.addCard();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
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
                  subtitle: Text(jobCardScreenController
                      .formatDate(jobCardScreenController.selectedDate.value)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                    ),
                    onPressed: () =>
                        jobCardScreenController.selectDateContext(context),
                    child: const Text('Select Date'),
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
                      child: const Center(child: Text('Fuel')),
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
                  ],
                )),
                
          ],
        ),
      ),
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
