import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditCardScreenController extends GetxController {
  var selectedDate = DateTime.now().obs;

  TextEditingController customerName = TextEditingController();
  TextEditingController carBrand = TextEditingController();
  TextEditingController carModel = TextEditingController();
  TextEditingController plateNumber = TextEditingController();
  TextEditingController carMileage = TextEditingController();
  TextEditingController chassisNumber = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController color = TextEditingController();
  RxString theDate = RxString('');
  RxDouble fuelAmount = RxDouble(25);
  var arguments = Get.arguments;

  @override
  void onInit() {
    setValuesToFields();
    super.onInit();
  }

  Future<void> selectDateContext(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate.value) {
      selectDate(picked);
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  // Function to format the date
  String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    theDate.value = formatter.format(date);
    return formatter.format(date);
  }

  // this function is to give the fields the values when i want to edit the selected car card
  void setValuesToFields() {
    if (Get.arguments == null) {
    } else {
      customerName.text = arguments.customerName;
      carBrand.text = arguments.carBrand;
      carModel.text = arguments.carModel;
      plateNumber.text = arguments.plateNumber;
      carMileage.text = arguments.carMileage;
      chassisNumber.text = arguments.chassisNumber;
      phoneNumber.text = arguments.phoneNumber;
      emailAddress.text = arguments.emailAddress;
      color.text = arguments.color;
      fuelAmount.value = arguments.fuelAmount;
    }
  }

  void editValues() {
    FirebaseFirestore.instance
        .collection('car_card')
        .doc(arguments.docID)
        .update({
      "customer_name": customerName.text,
      "car_brand": carBrand.text,
      "car_model": carModel.text,
      "plate_number": plateNumber.text,
      "car_mileage": carMileage.text,
      "chassis_number": chassisNumber.text,
      "phone_number": phoneNumber.text,
      "email_address": emailAddress.text,
      "color": color.text,
      "date": theDate.value,
      "fuel_amount": fuelAmount.value,
      "editing_time": FieldValue.serverTimestamp(),
    });
  }
}
