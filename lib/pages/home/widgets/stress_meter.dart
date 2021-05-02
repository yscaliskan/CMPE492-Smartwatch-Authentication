import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stress_detector/controllers/classification.dart';
import 'package:stress_detector/globals/colors.dart';
import 'package:stress_detector/globals/dimensions.dart';
import 'package:stress_detector/globals/shadows.dart';

class StressMeter extends StatelessWidget {
  double get size => [
        140.0,
        Get.height - Dimensions.pagePadding * 2,
        Get.width - Dimensions.pagePadding * 2,
      ].reduce(min);

  BoxShadow shadow(bool stressed) {
    if (stressed) return Shadows.redShadowNEW;
    return Shadows.greenShadowNEW;
  }

  Color color(bool stressed) {
    if (stressed) return CustomColors.red;
    return CustomColors.green;
  }

  String stressText(double stressLevel) {
    if (stressLevel < 0.5) return "You're doing great!";
    return "Relax your shoulders and take a deep breath";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassificationCtrlr>(builder: (ctrlr) {
      int stressPercent = ((ctrlr.stressLevel ?? 0) * 100).toInt();

      return ctrlr.stressed == null
          ? Text(
              'Welcome',
              style: GoogleFonts.amaticaSc(
                fontSize: 50,
                color: Colors.amber,
                fontWeight: FontWeight.normal,
              ),
            )
          : Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
                children: [
                  Container(
                    height: size,
                    width: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color(ctrlr.stressed),
                      borderRadius: BorderRadius.circular(size / 2),
                      boxShadow: [shadow(ctrlr.stressed)],
                    ),
                    child: Text(
                      '%$stressPercent',
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      stressText(ctrlr.stressLevel),
                      style: GoogleFonts.quicksand(
                        color: color(ctrlr.stressed),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
          );
    });
  }
}
