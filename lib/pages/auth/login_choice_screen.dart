import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/aiims_logo.png',
                height: size.height * 0.2,
              ),
              SizedBox(height: size.height * 0.05),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.1),
                  ),
                  minimumSize: Size(size.width * 0.6, size.height * 0.06),
                ),
                onPressed: () => Get.toNamed('/patientLogin'),
                child: Text(
                  'Login as Patient',
                  style: TextStyle(fontSize: size.width * 0.045),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.1),
                  ),
                  minimumSize: Size(size.width * 0.6, size.height * 0.06),
                ),
                onPressed: () => Get.toNamed('/doctorLogin'),
                child: Text(
                  'Login as Doctor',
                  style: TextStyle(fontSize: size.width * 0.045),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
