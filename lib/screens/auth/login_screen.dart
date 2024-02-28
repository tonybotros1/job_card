import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const.dart';
import '../../controllers/Auth controllers/login_screen_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginScreenController loginScreenController =
      Get.put(LoginScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
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
                        obscureText: false,
                        controller: loginScreenController.email,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validate: true),
                   Obx(() =>  myTextFormField(
                        icon: IconButton(
                            onPressed: () {
                              loginScreenController.changeObscureTextValue();
                            },
                            icon: Icon(loginScreenController.obscureText.value == true
                                ? Icons.remove_red_eye_outlined
                                : Icons.visibility_off)),
                        obscureText: loginScreenController.obscureText.value,
                        controller: loginScreenController.pass,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        validate: true)),
                    SizedBox(
                      height: 70,
                    ),
                    Obx(() => Container(
                          child: ElevatedButton(
                            onPressed:
                                loginScreenController.sigingInProcess == true
                                    ? null
                                    : () {
                                      
                                        loginScreenController.singIn();
                                      },
                            child:
                                loginScreenController.sigingInProcess == false
                                    ? Text(
                                        'Login',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

Padding myTextFormField(
    {required String labelText,
    required String hintText,
    required TextEditingController controller,
    required validate,
    required obscureText,
    IconButton? icon,
    keyboardType}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
    child: TextFormField(
      obscureText: obscureText,
      onTap: () {
        // controller.selection = TextSelection(
        //   baseOffset: 0,
        //   extentOffset: controller.text.length,
        // );
      },
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: icon,
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
