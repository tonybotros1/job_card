import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            icon: const Icon(Icons.done),
            onPressed: () {
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
              controller: editCardScreenController.customerName,
            ),
            myTextFormField(
              labelText: 'Car Brand:',
              hintText: 'Enter Car Brand here',
              controller: editCardScreenController.carBrand,
            ),
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
            myTextFormField(
              labelText: 'Color:',
              hintText: 'Enter Color here',
              controller: editCardScreenController.color,
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: ListTile(
                  title: Text(
                    "Date: ",
                    style: fontStyle,
                  ),
                  subtitle: Text(editCardScreenController
                      .formatDate(editCardScreenController.selectedDate.value)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                    ),
                    onPressed: () =>
                        editCardScreenController.selectDateContext(context),
                    child:const FittedBox(child: Text('Select Date')),
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
                      value:editCardScreenController.fuelAmount.value,
                      onChanged: (newValue) {
                        editCardScreenController.fuelAmount.value = newValue;
                      },
                      min: 0,
                      max: 100,
                      divisions: 4,
                      label: editCardScreenController.fuelAmount.value
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
