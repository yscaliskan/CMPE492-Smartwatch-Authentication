import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stress_detector/common_models/stress_result.dart';
import 'package:stress_detector/controllers/classification.dart';
import 'package:stress_detector/globals/constants.dart';
import 'package:stress_detector/globals/translations.dart';
import 'package:stress_detector/pages/home/homepage.dart';
import 'services/empatica.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.location.request();

  await Hive.initFlutter();
  Hive.registerAdapter(StressResultAdapter());
  await Hive.openBox<StressResult>(Constants.stressBoxName);

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
        GetPage(name: '/', page: () => HomePage(title: "Authenticator")),
      ],
    );
  }
}
