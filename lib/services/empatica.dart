import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ppg_authentication/common_models/sensor_data.dart';
import 'package:ppg_authentication/controllers/classification.dart';

const _channelName = 'ppg_authentication/empatica';

class EmpaticaService extends GetxController {
  MethodChannel _methodChannel;

  static bool bandConnected = false;

  EmpaticaService() {
    _methodChannel = MethodChannel(_channelName);
    _methodChannel.setMethodCallHandler(this._getEmpaticaData);
  }

  void _getSensorData(var args) async {
    var sensorDataMap = Map<String, double>.from(args);
    var sensorData = SensorData.fromMap(sensorDataMap);

 //   print(sensorData);

    ClassificationCtrlr.to.addData(sensorData);
  }

  void _updateBandConnection(var args) async {
    bandConnected = args;
    print(bandConnected);
    print("Band connection changed");
    update();
  }

  Future<void> _getEmpaticaData(MethodCall call) async {
    if (call.method == "getSensorData") _getSensorData(call.arguments);
    if(call.method == "bandConnection") _updateBandConnection(call.arguments);
  }
}
