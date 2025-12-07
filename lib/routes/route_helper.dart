import 'package:get/get.dart';
import 'package:digitaldailysis/pages/auth/LoginPage.dart';
import 'package:digitaldailysis/pages/auth/Splash_Screen.dart';
import 'package:digitaldailysis/pages/doctor/doctor_home_screen.dart';
import 'package:digitaldailysis/pages/patient/patient_home_screen.dart';
import 'package:digitaldailysis/pages/doctor/register_patient_page.dart';

class RouteHelper {
  // 🔹 Route names
  static const String splashPage = "/splash-page";
  static const String loginPage = "/login-page";
  static const String doctorHomeScreen = "/doctor-home-screen";
  static const String patientHomeScreen = "/patient-home-screen";
  static const String registerPatientScreen = "/register-patient-screen";

  // 🔹 Route builders
  static String getSplashPage() => splashPage;
  static String getLoginPage() => loginPage;
  static String getDoctorHomeScreen(String doctorId) =>
      "$doctorHomeScreen?doctorId=$doctorId";
  static String getPatientHomeScreen() => patientHomeScreen;
  static String getRegisterPatientScreen(String doctorId) =>
      "$registerPatientScreen?doctorId=$doctorId";

  // 🔹 Route list
  static List<GetPage> routes = [
    GetPage(
      name: splashPage,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: loginPage,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: doctorHomeScreen,
      page: () {
        var doctorId = Get.parameters['doctorId'];
        return DoctorHomePage(doctorId: doctorId ?? '');
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: patientHomeScreen,
      page: () => PatientHomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: registerPatientScreen,
      page: () {
        var doctorId = Get.parameters['doctorId'];
        return RegisterPatientPage(doctorId: doctorId ?? '');
      },
      transition: Transition.fadeIn,
    ),
  ];
}
