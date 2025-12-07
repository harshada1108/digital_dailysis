import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'package:digitaldailysis/helper/dependencies.dart' as dep;
import 'package:digitaldailysis/routes/route_helper.dart';

Future<void> main() async {
  //ensures that dependencies are loaded
  WidgetsFlutterBinding.ensureInitialized();
  //wait util dependencies are loaded
  await dep.init();

  //hide system navigation bar
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => runApp(MyApp()));

  // runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doczappoint',
      initialRoute: RouteHelper.getSplashPage(),
      getPages: RouteHelper.routes,
    );
  }
}

// Future<void> main() async {
//
//   //ensures that dependencies are loaded
//   WidgetsFlutterBinding.ensureInitialized();
//   //wait util dependencies are loaded
//   await dep.init();
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//
//     Get.find<CartController>().getCartData();
//     return GetBuilder<PopularProductController>(builder: (_){
//       return GetBuilder<RecommendedProductController>(builder: (_){
//         return GetMaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'Flutter Demo',
//
//           initialRoute: RouteHelper.getSplashPage(),
//           getPages: RouteHelper.routes,
//         );
//       });
//     },);
//   }
// }
