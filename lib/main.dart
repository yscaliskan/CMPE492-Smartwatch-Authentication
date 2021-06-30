import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ppg_authentication/controllers/classification.dart';
import 'package:ppg_authentication/globals/constants.dart';
import 'package:ppg_authentication/globals/translations.dart';
import 'package:ppg_authentication/pages/home/homepage.dart';
import 'services/empatica.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.location.request();

  Get.put(ClassificationCtrlr(), permanent: true);
  Get.put(EmpaticaService(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Constants.customTheme,
      translations: Dictionary(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en'),
      defaultTransition: Transition.rightToLeftWithFade,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomePage(title: "Smartwatch Authenticator")),
      ],
    );
  }
}
