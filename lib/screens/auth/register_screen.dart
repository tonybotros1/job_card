import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../const.dart';
import '../../controllers/Auth controllers/register_screen_controller.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final RegisterController registerScreenController =
      Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: GetBuilder<RegisterController>(
            init: RegisterController(),
            builder: (controller) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 130,
                          ),
                          Container(
                            child: Image.asset(
                              'assets/COMPASS_LOGO.jpg',
                            ),
                            width: Get.width,
                            height: 300,
                          ),
                          dropDownValues(
                            labelText: 'Area Name',
                            hintText: 'Enter Area Name',
                            controller: registerScreenController.name,
                            list: registerScreenController.areaName,
                            selectedValue:
                                registerScreenController.selectedAreaValue,
                            // validate: validate
                          ),
                          myTextFormField(
                            controller: controller.email,
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            // validate: true
                          ),
                          myTextFormField(
                            controller: controller.pass,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            // validate: true
                          ),
                          SizedBox(
                            height: 70,
                          ),
                          Container(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.register();
                              },
                              child: Text(
                                'Create Account',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }));
  }
}

Padding myTextFormField(
    {required String labelText,
    required String hintText,
    required TextEditingController controller,
    // required validate,
    keyboardType}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
    child: TextFormField(
      onTap: () {
        // controller.selection = TextSelection(
        //   baseOffset: 0,
        //   extentOffset: controller.text.length,
        // );
      },
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.grey),
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2.0)),
      ),
      // validator: validate != false
      //     ? (value) {
      //         if (value!.isEmpty) {
      //           return 'Please Enter $labelText';
      //         }
      //         return null;
      //       }
      //     : null,
    ),
  );
}

Padding dropDownValues({
  required String labelText,
  required String hintText,
  required TextEditingController controller,
  required List<String> list,
  required String selectedValue,
  // required bool validate,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
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
      // validator: validate != false
      //     ? (value) {
      //         if (value!.isEmpty) {
      //           return 'Please Enter $labelText';
      //         }
      //         return null;
      //       }
      //     : null,
    ),
  );
}
