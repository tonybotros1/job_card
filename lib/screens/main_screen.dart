
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/controllers/main_screen_controller.dart';
import '../const.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final MainScreenController mainScreenController =
      Get.put(MainScreenController());

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width >= 600; // Tablet breakpoint

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Work Order'),
        backgroundColor: mainColor,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: isTablet
                  ? Get.width / 4
                  : Get.width / 2.5, // Adjust width for tablet
              child: Column(
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
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              width: isTablet
                  ? Get.width / 4
                  : Get.width / 2, // Adjust width for tablet
              child: Column(
                children: [
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 30, 50),
                      child: ListTile(
                        title: Text(
                          "Date: ",
                          style: fontStyle,
                        ),
                        subtitle: Text(mainScreenController.formatDate(
                            mainScreenController.selectedDate.value)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                          ),
                          onPressed: () =>
                              mainScreenController.selectDateContext(context),
                          child: const Text('Select Date'),
                        ),
                      ),
                    ),
                  ),
                  Obx(() => Column(
                        children: [
                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   itemCount: mainScreenController.carState.length,
                          //   itemBuilder: (context, i) {
                          //     mainScreenController.isChecked.add(false);
                          //     return Padding(
                          //       padding: const EdgeInsets.all(16.0),
                          //       child: Row(
                          //         children: [
                          //           Text('${mainScreenController.carState[i]}'),
                          //           const SizedBox(
                          //             width: 10,
                          //           ),
                          //           MSHCheckbox(
                          //             size: 25,
                          //             value: mainScreenController.isChecked[i],
                          //             colorConfig: MSHColorConfig
                          //                 .fromCheckedUncheckedDisabled(
                          //               checkedColor: Colors.blue,
                          //             ),
                          //             style: MSHCheckboxStyle.stroke,
                          //             onChanged: (selected) {
                          //               // mainScreenController.isChecked[i] = selected;
                          //               mainScreenController.chech(i);
                          //             },
                          //           ),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),
                          Container(
                            color: mainColor,
                            height: 50,
                            child: const Center(child: Text('Fuel')),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Column(
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('E'),
                                  Text('H'),
                                  Text('F'),
                                ],
                              ),
                              Slider(
                                value: mainScreenController.discretValue.value,
                                onChanged: (newValue) {
                                  mainScreenController.discretValue.value =
                                      newValue;
                                },
                                min: 0,
                                max: 100,
                                divisions: 10,
                                label: mainScreenController.discretValue.value
                                    .round()
                                    .toString(),
                              ),
                            ],
                          ),
                        ],
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

Padding myTextFormField({required labelText, required hintText}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 10, 30, 10), // Adjust padding
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
