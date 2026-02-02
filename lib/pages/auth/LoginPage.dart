import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';
import 'package:digitaldailysis/utils/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: SizedBox(
              height: h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'images/aiims_logo-removebg-preview.png',
                      height: w * 0.4,
                    ),

                    SizedBox(height: h * 0.05),

                    // Title
                    Text(
                      "PD EXCHANGE",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: w * 0.065,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),

                    SizedBox(height: h * 0.01),

                    Text(
                      "Login to continue",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: w * 0.04,
                        color: AppColors.darkGrey,
                      ),
                    ),

                    SizedBox(height: h * 0.05),

                    // Login ID Field
                    TextField(
                      controller: loginIdController,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: w * 0.04,
                      ),
                      decoration: InputDecoration(
                        labelText: "Login ID",
                        labelStyle: TextStyle(
                          fontFamily: "Poppins",
                          color: AppColors.darkGrey,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.darkPrimary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w * 0.03),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w * 0.03),
                          borderSide: BorderSide(
                            color: AppColors.darkPrimary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.025),

                    // Password Field with Eye Icon
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: w * 0.04,
                      ),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontFamily: "Poppins",
                          color: AppColors.darkGrey,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.darkPrimary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.mediumGrey,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w * 0.03),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w * 0.03),
                          borderSide: BorderSide(
                            color: AppColors.darkPrimary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.05),

                    // Login Button / Loader
                    controller.isLoading
                        ? CircularProgressIndicator(
                      color: AppColors.darkPrimary,
                    )
                        : SizedBox(
                      width: double.infinity,
                      height: h * 0.065,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.login(
                            loginIdController.text.trim(),
                            passwordController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(w * 0.03),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontFamily: "Poppins",
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
          );
        },
      ),
    );
  }
}
