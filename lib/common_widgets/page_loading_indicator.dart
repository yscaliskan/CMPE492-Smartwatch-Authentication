import 'package:flutter/material.dart';
import 'package:stress_detector/globals/colors.dart';

class PageLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(CustomColors.black),
        ),
      ),
    );
  }
}
