import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:stress_detector/common_models/sensor_data.dart';
import 'package:stress_detector/common_models/stress_result.dart';
import 'package:stress_detector/globals/constants.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class _Constants {
  static const int windowLength = 60;

  static const double accMin = 50.022484;
  static const double accMax = 170.44026;
  static const double accRange = accMax - accMin;

  static const double bvpMin = -886.73846;
  static const double bvpMax = 1043.9814;
  static const double bvpRange = bvpMax - bvpMin;

  static const double edaMin = 0.0;
  static const double edaMax = 85.21792;
  static const double edaRange = edaMax - edaMin;

  static const double tempMin = 2.63;
  static const double tempMax = 37.565;
  static const double tempRange = tempMax - tempMin;
}

class ClassificationCtrlr extends GetxController {
  static ClassificationCtrlr get to => Get.find();

  Interpreter interpreter;

  SensorData currentData;
  List<SensorData> dataList;

  bool predicting;
  bool stressed;
  double stressLevel;

  ClassificationCtrlr() {
    predicting = false;
    dataList = [];
    _loadModel();
  }

  @override
  void onClose() {
    interpreter?.close();
    super.onClose();
  }

  void addData(SensorData newData) {
    currentData = SensorData(
      newData.acc,
      newData.bvp,
      newData.eda,
      newData.temp,
    );

    _normalize(newData);

    if (dataList.length < _Constants.windowLength)
      dataList.add(newData);
    else {
      dataList.removeAt(0);
      dataList.add(newData);
      if (interpreter != null && !predicting) _predictStress(dataList);
    }

    update();
  }

  void _predictStress(List<SensorData> windowData) {
    predicting = true;
    var stressHist = Hive.box<StressResult>(Constants.stressBoxName);
    var stressRes = StressResult(dateTime: DateTime.now());

    var input = windowData.map((data) => data.toList).toList().reshape(
      [1, _Constants.windowLength, 4],
    );
    var output = List(1 * 1).reshape([1, 1]);
    interpreter.run(input, output);

    stressLevel = output[0][0];
    stressed = stressLevel > 0.5;

    stressRes.val = stressLevel;
    stressHist.add(stressRes);

    predicting = false;
  }

  void _normalize(data) {
    data.acc = (data.acc - _Constants.accMin) / _Constants.accRange;
    data.bvp = (data.bvp - _Constants.bvpMin) / _Constants.bvpRange;
    data.eda = (data.eda - _Constants.edaMin) / _Constants.edaRange;
    data.temp = (data.temp - _Constants.tempMin) / _Constants.tempRange;
  }

  void _loadModel() async {
    interpreter = await Interpreter.fromAsset('model.tflite');
  }
}
