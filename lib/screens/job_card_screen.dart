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
            onPressed: () {},
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
            ),
            myTextFormField(
              labelText: 'Car Brand:',
              hintText: 'Enter Car Brand here',
            ),
            myTextFormField(
              labelText: 'Car Model:',
              hintText: 'Enter Car Model here',
            ),
            myTextFormField(
              labelText: 'Plate Number:',
              hintText: 'Enter Plate Number here',
            ),
            myTextFormField(
              labelText: 'Car Mileage:',
              hintText: 'Enter Car Mileage here',
            ),
            myTextFormField(
              labelText: 'Chassis Number:',
              hintText: 'Enter Chassis Number here',
            ),
            myTextFormField(
              labelText: 'Phone Number:',
              hintText: 'Enter Phone Number here',
            ),
            myTextFormField(
              labelText: 'Email Address:',
              hintText: 'Enter Email Address here',
            ),
            myTextFormField(
              labelText: 'Color:',
              hintText: 'Enter Color here',
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
                      value: jobCardScreenController.discretValue.value,
                      onChanged: (newValue) {
                        jobCardScreenController.discretValue.value = newValue;
                      },
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: jobCardScreenController.discretValue.value
                          .round()
                          .toString(),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

Padding myTextFormField({required labelText, required hintText}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 5, 30, 5), // Adjust padding
    child: TextFormField(
      // controller: ,
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
