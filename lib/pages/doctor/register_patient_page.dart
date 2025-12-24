import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/controllers/doctor_controller.dart';
import 'package:digitaldailysis/utils/colors.dart';

class RegisterPatientPage extends StatefulWidget {
  final String doctorId;

  const RegisterPatientPage({super.key, required this.doctorId});

  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final doctorController = Get.find<DoctorController>();
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: AppBar(
        backgroundColor: AppColors.darkPrimary,
        title: Text(
          "Register New Patient",
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.08,
            vertical: h * 0.03,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Title
                Text(
                  "Patient Details",
                  style: TextStyle(
                    fontSize: w * 0.055,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),

                SizedBox(height: h * 0.03),

                // Name
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration(
                    label: "Name",
                    icon: Icons.person_outline,
                    w: w,
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? "Please enter patient name"
                      : null,
                ),

                SizedBox(height: h * 0.025),

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    label: "Email",
                    icon: Icons.email_outlined,
                    w: w,
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? "Please enter email"
                      : null,
                ),

                SizedBox(height: h * 0.025),

                // Password with eye icon
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: _inputDecoration(
                    label: "Password",
                    icon: Icons.lock_outline,
                    w: w,
                    suffix: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
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

                // Register button / loader
                doctorController.isLoading
                    ? CircularProgressIndicator(
                  color: AppColors.darkPrimary,
                )
                    : SizedBox(
                  width: double.infinity,
                  height: h * 0.065,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await doctorController.registerPatient(
                          nameController.text.trim(),
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          widget.doctorId,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(w * 0.03),
                      ),
                    ),
                    child: Text(
                      "Register Patient",
                      style: TextStyle(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Common InputDecoration
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
