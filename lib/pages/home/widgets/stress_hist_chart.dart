import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:ppg_authentication/common_models/stress_result.dart';
import 'package:ppg_authentication/globals/colors.dart';
import 'package:ppg_authentication/globals/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:ui';

bool _demo = true;
final int _daysToShow = 7;

class StressHistChart extends StatefulWidget {
  @override
  _StressHistChartState createState() => _StressHistChartState();
}

class _StressHistChartState extends State<StressHistChart> {
  final List<Color> gradientColors = [
    CustomColors.green,
    Colors.amber,
    CustomColors.red,
  ];

  Map<int, Map<int, FlSpot>> daySpots = {}; // day: {hour: spot}
  DateTime selectedDate = DateTime.now();
  PageController pageCtrlr = PageController(initialPage: _daysToShow - 1);
  Random rand = Random();

  List<FlSpot> demoSpots(int day) {
    var rand = Random(day);
    List<FlSpot> res = [];

    int upperHourLimit = 24;
    if(day == DateTime.now().day) upperHourLimit = DateTime.now().hour;

    for (int i = 0; i < upperHourLimit; i++) {
      res.add(FlSpot(i.toDouble(), rand.nextDouble() * 100));
    }
    return res;
  }

  @override
  void initState() {
    for (int i = 0; i < _daysToShow; i++)
      updateSpotWithDay(
        Hive.box<StressResult>(Constants.stressBoxName),
        DateTime.now().subtract(Duration(days: i)),
      );
    super.initState();
  }

  void updateSpotWithDay(Box<StressResult> box, DateTime date) {
    daySpots[date.day] = {};

    for (int hour = 0; hour < 24; hour++) {
      Iterable hourResults = box.values.where((res) {
        return res.dateTime.day == date.day &&
            res.dateTime.month == date.month &&
            res.dateTime.year == date.year &&
            res.dateTime.hour == hour;
      });

      if (hourResults.isNotEmpty) {
        double avg = hourResults.map((res) => res.val).reduce((a, b) => a + b) /
            hourResults.length;
        int hourAvgPercent = (avg * 100).round();
        daySpots[date.day][hour] =
            FlSpot(hour.toDouble(), hourAvgPercent.toDouble());
      }
    }
  }

  Color percentColor(int percent) {
    switch (percent) {
      case 0:
        return gradientColors[0];
      case 50:
        return gradientColors[1];
      case 100:
        return gradientColors[2];
      default:
        return null;
    }
  }

  Color fusedPercentColor(int percent) {
    if (percent <= 50)
      return Color.alphaBlend(
        gradientColors[0].withOpacity((50 - percent) / 50),
        gradientColors[1].withOpacity(percent / 50),
      );

    return Color.alphaBlend(
      gradientColors[1].withOpacity((100 - percent) / 50),
      gradientColors[2].withOpacity((percent - 50) / 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    double chartWidth = Get.width;
    double chartHeight = chartWidth / 1.7;

    LineChartData data() => LineChartData(
          lineTouchData: LineTouchData(
            enabled: _demo
                ? true
                : (daySpots[selectedDate.day]?.isNotEmpty ?? false),
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 30,
              tooltipBgColor: Colors.blueGrey[700],
              getTooltipItems: (spots) {
                return spots
                    .map(
                      (s) => LineTooltipItem(
                        '${s.y.toInt()}%',
                        TextStyle(
                          color: fusedPercentColor(s.y.toInt()),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .toList();
              },
            ),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            horizontalInterval: 50,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xff37434d),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: SideTitles(
              showTitles: false,
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTextStyles: (value) => TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              getTitles: (value) {
                if (value.toInt() % 4 == 1) return '${value.toInt()}:00';
                return '';
              },
              margin: 8,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: 0,
          maxX: 23,
          minY: 0,
          maxY: 100,
          lineBarsData:
              (_demo ? false : (daySpots[selectedDate.day]?.isEmpty ?? true))
                  ? [
                      LineChartBarData(
                        spots: [FlSpot(0, 0)],
                        dotData: FlDotData(show: false),
                      ),
                    ]
                  : [
                      LineChartBarData(
                        spots: _demo
                            ? demoSpots(selectedDate.day)
                            : daySpots[selectedDate.day].values.toList(),
                        isCurved: true,
                        colors: gradientColors,
                        gradientFrom: Offset(0.5, 1.0),
                        gradientTo: Offset(0.5, 0.0),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: _demo
                              ? false
                              : daySpots[selectedDate.day].values.length == 1,
                          getDotPainter: (spot, value, barData, i) =>
                              FlDotCirclePainter(
                            color: fusedPercentColor(spot.y.toInt()),
                          ),
                        ),
                        curveSmoothness: 0.15,
                        belowBarData: BarAreaData(
                          show: true,
                          gradientFrom: Offset(0.5, 1.0),
                          gradientTo: Offset(0.5, 0.0),
                          colors: gradientColors
                              .map((color) => color.withOpacity(0.3))
                              .toList(),
                        ),
                      ),
                    ],
        );

    return ValueListenableBuilder<Box<StressResult>>(
      valueListenable:
          Hive.box<StressResult>(Constants.stressBoxName).listenable(),
      builder: (context, box, widget) {
        updateSpotWithDay(box, DateTime.now());

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selectedDate.day == DateTime.now().day - _daysToShow + 1
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.transparent,
                        ),
                        onPressed: null,
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => pageCtrlr.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                      ),
                Expanded(
                  child: Container(
                    height: 36,
                    child: PageView.builder(
                      controller: pageCtrlr,
                      itemCount: _daysToShow,
                      physics: NeverScrollableScrollPhysics(),
                      onPageChanged: (int i) => setState(
                        () => selectedDate = DateTime.now().subtract(
                          Duration(days: _daysToShow - 1 - i),
                        ),
                      ),
                      itemBuilder: (ctx, i) {
                        DateTime buttonDate = DateTime.now()
                            .subtract(Duration(days: _daysToShow - 1 - i));

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              buttonDate.day == DateTime.now().day
                                  ? 'Today'
                                  : DateFormat('EEE, d MMM').format(buttonDate),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                selectedDate.day == DateTime.now().day
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.transparent,
                        ),
                        onPressed: null,
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => pageCtrlr.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                      ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              height: chartHeight,
              width: chartWidth,
              padding: EdgeInsets.only(right: 16, left: 16),
              child: LineChart(data()),
            ),
          ],
        );
      },
    );
  }
}

// List<Widget>.generate(
// daysToShow,
// (i) {

//
// return IconButton(
// icon: Text(
// buttonDate.day.toString(),
// textAlign: TextAlign.center,
// style: TextStyle(
// fontSize: 16,
// fontWeight: FontWeight.bold,
// color: selectedDate.day == buttonDate.day
// ? Colors.amber
//     : Colors.white,
// ),
// ),
// onPressed: () =>

// );
// },
// ),
