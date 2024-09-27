import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
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
      body: KeyboardListener(
        autofocus: true,
        focusNode: loginScreenController.focusNode,
          onKeyEvent: (KeyEvent event) {
          // if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            loginScreenController.singIn(); // Call the login function when "Enter" is pressed
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight / 20,
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight > 400
                              ? constraints.maxHeight / 2
                              : constraints.maxHeight / 1.5,
                          maxWidth: constraints.maxWidth > 600
                              ? constraints.maxWidth / 2
                              : constraints.maxWidth / 1.5),
                      // width: constraints.maxWidth > 600
                      //     ? 400
                      //     : Get.width * 0.8, // Responsive width
                      // height: 300,
                      child: Image.asset(
                        'assets/COMPASS_LOGO.jpg',
                      ),
                    ),
                    myTextFormField(
                      constraints: constraints,
                      obscureText: false,
                      controller: loginScreenController.email,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validate: true,
                    ),
                    Obx(() => myTextFormField(
                          constraints: constraints,
                          icon: IconButton(
                              onPressed: () {
                                loginScreenController.changeObscureTextValue();
                              },
                              icon: Icon(loginScreenController.obscureText.value
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.visibility_off)),
                          obscureText: loginScreenController.obscureText.value,
                          controller: loginScreenController.pass,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          validate: true,
                        )),
                     SizedBox(
                      height:  constraints.maxHeight / 10,
                    ),
                    Obx(() => ElevatedButton(
                          onPressed: loginScreenController.sigingInProcess.value
                              ? null
                              : () {
                                  loginScreenController.singIn();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                          ),
                          child:
                              loginScreenController.sigingInProcess.value == false
                                  ? const Text(
                                      'Login',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget myTextFormField({
  required String labelText,
  required String hintText,
  required TextEditingController controller,
  required validate,
  required obscureText,
  IconButton? icon,
  required constraints,
  keyboardType,
}) {
  return Container(
    constraints: BoxConstraints(
        maxHeight:constraints.maxHeight > 400 ? constraints.maxHeight / 3: constraints.maxHeight / 1.3,
        maxWidth:constraints.maxWidth > 600 ? constraints.maxWidth / 3: constraints.maxWidth / 1.3),
    child: TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: icon,
        hintStyle: const TextStyle(color: Colors.grey),
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 2.0),
        ),
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
