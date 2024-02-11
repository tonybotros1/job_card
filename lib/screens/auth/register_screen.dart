import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const.dart';
import '../../controllers/Auth controllers/login_screen_controller.dart';
import '../../controllers/Auth controllers/register_screen_controller.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final RegisterController RegisterScreenController =
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
                          myTextFormField(
                              controller: controller.email,
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              validate: true),
                          myTextFormField(
                              controller: controller.pass,
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              validate: true),
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
    required validate,
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
