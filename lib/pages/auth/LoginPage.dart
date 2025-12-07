import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController loginIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/aiims_logo-removebg-preview.png',
                    height: size.width * 0.4,
                  ),
                  SizedBox(height: size.height * 0.05),
                  TextField(
                    controller: loginIdController,
                    decoration: const InputDecoration(
                      labelText: 'Login ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  controller.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () {
                      controller.login(
                        loginIdController.text.trim(),
                        passwordController.text.trim(),
                      );
                    },
                    child: const Text("Login"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
