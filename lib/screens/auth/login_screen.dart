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
                    const SizedBox(
                      height: 130,
                    ),
                    SizedBox(
                      width: Get.width,
                      height: 300,
                      child: Image.asset(
                        'assets/COMPASS_LOGO.jpg',
                      ),
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
                    const SizedBox(
                      height: 70,
                    ),
                    Obx(() => ElevatedButton(
                      onPressed:
                          loginScreenController.sigingInProcess.value == true
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








// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../const.dart';
// import '../../controllers/Auth controllers/login_screen_controller.dart';

// class LoginScreen extends StatelessWidget {
//   LoginScreen({super.key});

//   final LoginScreenController loginScreenController =
//       Get.put(LoginScreenController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: 130,
//                   ),
//                   Container(
//                     child: Image.asset(
//                       'assets/COMPASS_LOGO.jpg',
//                       fit: BoxFit.cover,
//                     ),
//                     width: Get.width,
//                     height: 300,
//                   ),
//                   myTextFormField(
//                     obscureText: false,
//                     controller: loginScreenController.email,
//                     labelText: 'Email',
//                     hintText: 'Enter your email',
//                     keyboardType: TextInputType.emailAddress,
//                     validate: true,
//                   ),
//                   Obx(() => myTextFormField(
//                     icon: IconButton(
//                       onPressed: () {
//                         loginScreenController.changeObscureTextValue();
//                       },
//                       icon: Icon(
//                         loginScreenController.obscureText.value
//                             ? Icons.remove_red_eye_outlined
//                             : Icons.visibility_off,
//                       ),
//                     ),
//                     obscureText: loginScreenController.obscureText.value,
//                     controller: loginScreenController.pass,
//                     labelText: 'Password',
//                     hintText: 'Enter your password',
//                     validate: true,
//                   )),
//                   SizedBox(
//                     height: 70,
//                   ),
//                   Obx(() => Container(
//                     child: ElevatedButton(
//                       onPressed: loginScreenController.sigingInProcess
//                           ? null
//                           : () {
//                               loginScreenController.singIn();
//                             },
//                       child: loginScreenController.sigingInProcess
//                           ? Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             )
//                           : Text(
//                               'Login',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: mainColor,
//                       ),
//                     ),
//                   ))
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Padding myTextFormField({
//   required String labelText,
//   required String hintText,
//   required TextEditingController controller,
//   required bool validate,
//   required bool obscureText,
//   IconButton? icon,
//   TextInputType? keyboardType,
// }) {
//   return Padding(
//     padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
//     child: TextFormField(
//       obscureText: obscureText,
//       onTap: () {
//         // controller.selection = TextSelection(
//         //   baseOffset: 0,
//         //   extentOffset: controller.text.length,
//         // );
//       },
//       keyboardType: keyboardType,
//       controller: controller,
//       decoration: InputDecoration(
//         suffixIcon: icon,
//         hintStyle: const TextStyle(color: Colors.grey),                      
//         labelText: labelText,
//         hintText: hintText,
//         labelStyle: TextStyle(color: Colors.grey.shade700),
//         focusedBorder: const UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.grey, width: 2.0),
//         ),
//       ),
//       validator: validate
//           ? (value) {
//               if (value!.isEmpty) {
//                 return 'Please Enter $labelText';
//               }
//               return null;
//             }
//           : null,
//     ),
//   );
// }
