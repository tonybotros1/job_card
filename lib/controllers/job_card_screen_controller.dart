import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class JobCardScreenController extends GetxController {
  var selectedDate = DateTime.now().obs;
  RxList carState = RxList(['New', 'Returned']);
  RxList<bool> isChecked = RxList([]);
  TextEditingController customerName = TextEditingController();
  TextEditingController carBrand = TextEditingController();
  TextEditingController carModel = TextEditingController();
  TextEditingController plateNumber = TextEditingController();
  TextEditingController carMileage = TextEditingController();
  TextEditingController chassisNumber = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController color = TextEditingController();

  RxDouble discretValue = RxDouble(20);

  void selectDate(DateTime date) {
    selectedDate.value = date;
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

  // Function to format the date
  String formatDate(DateTime date) {
    final formatter =
        DateFormat('yyyy-MM-dd'); // Customize the format as needed
    return formatter.format(date);
  }

  // Function to check or uncheck the box
  void chech(i) {
    if (isChecked[i] == true) {
      isChecked[i] = false;
    } else {
      isChecked[i] = true;
    }
  }

// this function is to add the car card when all informations addedd
  void addCard(){
    
  }

}
