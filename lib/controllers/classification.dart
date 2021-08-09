import 'package:get/get.dart';
import 'package:ppg_authentication/common_models/sensor_data.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../pages/home/homepage.dart';

class _Constants {
  static const int windowLength = 30;

}

class ClassificationCtrlr extends GetxController {
  static ClassificationCtrlr get to => Get.find();

  Interpreter interpreter;

  SensorData currentData;
  List<SensorData> dataList;

  static int counter_false = 0;
  static int counter_true = 0;
  int prediction = 0;
  static String userName = "";
  static double threshold = 0;

  static bool goBackToHomePage = false;
  static int counter_notonwrist = 0;
  static bool onWrist = false;
  static bool authenticationState = true;

  bool predicting;


  ClassificationCtrlr() {
    predicting = false;
    dataList = [];
    loadModel();
  }

  @override
  void onClose() {
    interpreter?.close();
    super.onClose();
  }

  void onWristStatusChanged(bool status) {
    onWrist = status;
  }

  void setAuthenticationState(bool authState) {
    print("set authentication state: " + authState.toString());
    dataList.clear();
    prediction = 0;
    authenticationState = authState;
  }

  void addData(SensorData newData) {

    currentData = SensorData(
      newData.temp,
      newData.accx,
      newData.accy,
      newData.accz,
      newData.eda,
      newData.bvp,
    );

    if (!onWrist) {
      counter_notonwrist += 1;
      print("counter_onwrist: " + counter_notonwrist.toString());
      print("onwrist: " + onWrist.toString());
    }
    else {
      if (counter_notonwrist >= 3) {
        prediction = 0;
      }
      counter_notonwrist = 0;
    }

    if (counter_notonwrist >= 3) {
      //Get.to(HomePage(title: "Smartwatch Authenticator"));
      dataList.clear();
      prediction = 3;
    }

    if (dataList.length < _Constants.windowLength && authenticationState) {
      dataList.add(newData);
    }

    else {
      dataList.removeAt(0);
      dataList.add(newData);
      if (interpreter != null && !predicting && counter_notonwrist <= 3 && authenticationState){
        _authenticate(dataList);
      }
    }

    update();
  }

  void _authenticate(List<SensorData> windowData) {
    predicting = true;

    var input = windowData.map((data) => data.toList).toList().reshape(
      [1, _Constants.windowLength, 6],
    );
    print(input);
    var output = List(1 * 1).reshape([1, 1]);
    interpreter.run(input, output);

    if (output[0][0] >= threshold && (counter_true < 5 && counter_false < 3)){
      counter_true += 1;
      counter_false = 0;
    }
    else if(output[0][0] >= threshold && (counter_true < 5 && counter_false == 3)){
      counter_true += 1;
      if (counter_true == 5){
        counter_false = 0;
      }
    }
    else if(output[0][0] >= threshold   && (counter_true == 5 && counter_false < 3)){
      counter_false = 0;
    }
    else if (output[0][0] <  threshold && (counter_true < 5 && counter_false < 3)){
      counter_false += 1 ;
      counter_true = 0;
    }
    else if(output[0][0] <  threshold && (counter_true < 5 && counter_false == 3)){
      counter_true = 0;
    }
    else if(output[0][0] <  threshold && (counter_true == 5 && counter_false < 3)){
      counter_false +=1;
      if (counter_false == 3 ){
        counter_true = 0;
      }
    }
    print("---------------------OUTPUTTTT----------------------------");
    print(output);

    print('-------------------');
    if(counter_true ==5 ){
      prediction = 1;
      print('YESSSSSSSSSSSSSSSSSSSSS');
    }
    else if(counter_false == 3 ){
      prediction = 2;
      print('NOOOOOOOOOOOOOOOOOO');
    }

    predicting = false;
  }

  void loadModel() async {
    switch(userName) {
      case "Ahmet Şentürk":
        threshold = 0.00000035;
        interpreter = await Interpreter.fromAsset('model_ahmet_senturk_get_lstm_big_dataset_15_sec.tflite');
        break;

      case "Ahmet Yiğit Gedik":
        threshold = 0.104;
        interpreter = await Interpreter.fromAsset('model_ahmet_gedik_get_lstm_big_dataset_15_sec.tflite');
        break;

      case "Yaşar Selçuk Çalışkan":
        threshold = 0.99;
        interpreter = await Interpreter.fromAsset('big_dataset_yasar.tflite');
        break;

      case "":
        print("Chosen Person is blank.");
        //interpreter = await Interpreter.fromAsset('big_dataset_ahmet_senturk.tflite');
        break;
    }
  }
}
