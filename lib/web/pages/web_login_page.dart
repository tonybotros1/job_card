import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/Auth controllers/login_screen_controller.dart';
import '../web_theme.dart';
import '../web_widgets.dart';

/// Web sign-in page. Reuses [LoginScreenController] (Firebase e-mail + password).
class WebLoginPage extends StatelessWidget {
  const WebLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LoginScreenController());
    return Scaffold(
      backgroundColor: WebColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: WebSurface(
              padding: const EdgeInsets.all(32),
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset('assets/COMPASS_LOGO.jpg', height: 110, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sign in',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Job Card portal for Compass Automatic Gear',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: WebColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: c.email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.mail_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => TextField(
                        controller: c.pass,
                        obscureText: c.obscureText.value,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => c.sigingInProcess.value ? null : c.singIn(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            tooltip: c.obscureText.value ? 'Show password' : 'Hide password',
                            icon: Icon(
                              c.obscureText.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: c.changeObscureTextValue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: c.sigingInProcess.value ? null : c.singIn,
                          child: c.sigingInProcess.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
