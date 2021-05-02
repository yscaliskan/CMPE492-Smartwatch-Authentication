import 'package:flutter/material.dart';
import 'package:stress_detector/globals/colors.dart';

class Shadows {
  static const yellowShadowNEW = BoxShadow(
    color: Color(0x80FCB34B),
    offset: Offset(0, 2),
    spreadRadius: 1,
    blurRadius: 3,
  );

  static final greenShadowNEW = BoxShadow(
    color: CustomColors.green.withOpacity(0.5),
    offset: Offset(0, 2),
    spreadRadius: 1,
    blurRadius: 3,
  );

  static final redShadowNEW = BoxShadow(
    color: CustomColors.red.withOpacity(0.5),
    offset: Offset(0, 2),
    spreadRadius: 1,
    blurRadius: 3,
  );

  static final blueShadowNEW = BoxShadow(
    color: CustomColors.blue.withOpacity(0.5),
    offset: Offset(0, 2),
    spreadRadius: 1,
    blurRadius: 3,
  );

  static const grayShadowNEW = BoxShadow(
    color: Color(0x204C5BE2),
    offset: Offset(0, 10),
    spreadRadius: 0,
    blurRadius: 13,
  );
}
