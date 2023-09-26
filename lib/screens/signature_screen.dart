import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/const.dart';
import 'package:job_card/controllers/signature_screen_controller.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatelessWidget {
  SignatureScreen({super.key});

  final MySignatureController signatureController =
      Get.put(MySignatureController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('Customer Signature'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: GetBuilder(
          init: MySignatureController(),
          builder: (controller) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: Get.width,
                  height: Get.height / 2,
                  child: Signature(
                    controller: controller.controller,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                      ),
                      onPressed: () {
                        controller.controller.clear();
                      },
                      child: const Text('Clear'),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                      ),
                      onPressed: () async {
                        controller.signatureAsImage =
                            await controller.controller.toPngBytes();
                      },
                      child: const Text('Save'),
                    )
                  ],
                ),
              ],
            );
          }),
    );
  }
}
