// lib/pages/doctor/step1_basic_registration.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/controllers/patient_registration_controller.dart';
import 'package:digitaldailysis/utils/colors.dart';

class Step1BasicRegistration extends StatefulWidget {
  final String doctorId;
  final PatientRegistrationController controller;

  const Step1BasicRegistration({super.key, required this.controller, required this.doctorId});

  @override
  State<Step1BasicRegistration> createState() => _Step1BasicRegistrationState();
}

class _Step1BasicRegistrationState extends State<Step1BasicRegistration> {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.all(w * 0.05),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step 1: Basic Registration",
              style: TextStyle(
                fontSize: w * 0.055,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: h * 0.01),
            Text(
              "Enter patient's basic credentials",
              style: TextStyle(
                fontSize: w * 0.038,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: h * 0.03),

            TextFormField(
              controller: widget.controller.nameController,
              decoration: _inputDecoration(
                label: "Full Name",
                icon: Icons.person_outline,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Please enter name" : null,
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                label: "Email",
                icon: Icons.email_outlined,
                w: w,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Please enter email";
                if (!GetUtils.isEmail(value)) return "Invalid email";
                return null;
              },
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                label: "Phone Number",
                icon: Icons.phone_outlined,
                w: w,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Please enter phone";
                if (value.length < 10) return "Invalid phone number";
                return null;
              },
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.passwordController,
              obscureText: !isPasswordVisible,
              decoration: _inputDecoration(
                label: "Password",
                icon: Icons.lock_outline,
                w: w,
                suffix: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.mediumGrey,
                    size: w * 0.06,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) =>
              value == null || value.length < 6
                  ? "Minimum 6 characters required"
                  : null,
            ),
            SizedBox(height: h * 0.05),

            Obx(() => widget.controller.isLoading.value
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.darkPrimary,
              ),
            )
                : SizedBox(
              width: double.infinity,
              height: h * 0.065,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await widget.controller.registerPatient(widget.doctorId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.03),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Next: Medical Profile",
                      style: TextStyle(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(width: w * 0.02),
                    Icon(Icons.arrow_forward, color: AppColors.white),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required double w,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: AppColors.darkPrimary,
        size: w * 0.06,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
        borderSide: BorderSide(
          color: AppColors.darkPrimary,
          width: 2,
        ),
      ),
    );
  }
}