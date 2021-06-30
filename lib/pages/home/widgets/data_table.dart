import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ppg_authentication/common_models/sensor_data.dart';
import 'package:ppg_authentication/controllers/classification.dart';

class SensorDataTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget dataRow(String label, double data) {
      return Row(
        children: [
          Container(
            width: 40,
            child: Text(
              label,
              style: GoogleFonts.quicksand(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            margin: EdgeInsets.symmetric(horizontal: 10),
            color: Colors.grey[400],
          ),
          Text(
            data.toString(),
            style: GoogleFonts.quicksand(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return GetBuilder<ClassificationCtrlr>(builder: (ctrlr) {
      SensorData data = ctrlr.currentData;

      if (data == null)
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(10),
          child: Text(
            "Didn't receive any data yet",
            style: GoogleFonts.quicksand(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              'Current Sensor Data',
              style: GoogleFonts.quicksand(
                color: Colors.blue[900],
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(color: Colors.grey[400]),
            dataRow('ACC', data.accx),
            dataRow('BVP', data.bvp),
            dataRow('EDA', data.eda),
            dataRow('TEMP', data.temp),
          ],
        ),
      );
    });
  }
}
