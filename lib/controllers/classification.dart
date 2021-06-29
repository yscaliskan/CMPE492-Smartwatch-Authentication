import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:stress_detector/common_models/sensor_data.dart';
import 'package:stress_detector/common_models/stress_result.dart';
import 'package:stress_detector/globals/constants.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class _Constants {
  static const int windowLength = 120;

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

  static int counter_false = 0;
  static int counter_true = 0;
  int prediction = 0;
  String userName = "";

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
      newData.temp,
      newData.accx,
      newData.accy,
      newData.accz,
      newData.eda,
      newData.bvp,
    );

  //   _normalize(newData);

    if (dataList.length < _Constants.windowLength)
      dataList.add(newData);
    else {
      dataList.removeAt(0);
      dataList.add(newData);
      if (interpreter != null && !predicting) _authenticate(dataList);
    }

    update();
  }

  void _authenticate(List<SensorData> windowData) {
    predicting = true;
    //var stressHist = Hive.box<StressResult>(Constants.stressBoxName);
    //var stressRes = StressResult(dateTime: DateTime.now());

    var input = windowData.map((data) => data.toList).toList().reshape(
      [1, _Constants.windowLength, 6],
    );
    print(input);
    //var input = [[[808336064.0, 101042000.0, 101042064.0, 101042024.0, 808336064.0, 50521008.0], [31.290000915527344, -14.75, 60.3125, 17.8125, 0.1082725003361702, 25.61687469482422], [31.290000915527344, -17.25, 61.5, 15.9375, 0.27356401085853577, 33.5256233215332], [31.290000915527344, -18.75, 62.5625, 14.625, 0.2742049992084503, -121.81843566894531], [31.290000915527344, -8.25, 62.25, 22.3125, 0.2742049992084503, 61.278438568115234], [31.309999465942383, -8.625, 68.125, 8.375, 0.27292299270629883, 0.8134375214576721], [31.309999465942383, -9.9375, 57.375, 26.125, 0.27292299270629883, 4.104374885559082], [31.309999465942383, -2.5, 58.3125, 32.5625, 0.2729234993457794, -7.132500171661377], [31.309999465942383, -37.6875, 61.0, -1.6875, 0.276126503944397, 13.278124809265137], [31.329999923706055, -13.0, 57.75, 18.0, 0.2710014879703522, -34.91468811035156], [31.329999923706055, -13.8125, 71.0625, 24.4375, 0.26843899488449097, -78.95780944824219], [31.329999923706055, -24.6875, 56.75, 2.0, 0.26843899488449097, 153.0087432861328], [31.329999923706055, -12.5, 58.0625, 27.875, 0.26715749502182007, 29.092187881469727], [31.309999465942383, -8.6875, 70.5625, 11.75, 0.2665170133113861, -176.5206298828125], [31.309999465942383, -10.375, 66.5625, 16.375, 0.26843899488449097, 136.70094299316406], [31.329999923706055, 4.3125, 56.3125, 31.5625, 0.26459500193595886, -33.790313720703125], [31.329999923706055, -2.625, 60.875, 27.875, 0.2652359902858734, 82.35406494140625], [31.309999465942383, 0.4375, 56.875, 26.3125, 0.26459500193595886, -47.05406188964844], [31.309999465942383, -1.5625, 59.5625, 28.0625, 0.26459500193595886, -0.6949999928474426], [31.329999923706055, -0.3125, 58.875, 27.0625, 0.2652359902858734, -11.539999961853027], [31.329999923706055, -0.8125, 58.375, 27.1875, 0.2652355134487152, -28.999374389648438], [31.350000381469727, -1.25, 58.5625, 27.6875, 0.26459500193595886, -1.1534374952316284], [31.350000381469727, -0.5, 57.375, 28.75, 0.2652359902858734, -14.2446870803833], [31.329999923706055, -0.0625, 59.3125, 27.9375, 0.26459500193595886, -4.672500133514404], [31.329999923706055, 0.75, 58.8125, 26.25, 0.26459500193595886, 0.5728124976158142], [31.329999923706055, -1.0625, 58.75, 27.125, 0.2639540135860443, -2.6328125], [31.329999923706055, 1.0, 58.5625, 25.4375, 0.2639540135860443, 8.303125381469727], [31.309999465942383, -1.0, 59.4375, 27.3125, 0.2639540135860443, 3.0718750953674316], [31.309999465942383, -0.1875, 59.0625, 27.6875, 0.2639540135860443, 7.174062728881836], [31.309999465942383, 0.8125, 57.75, 27.3125, 0.26331350207328796, -8.725312232971191], [31.309999465942383, -19.3125, 55.375, 27.125, 0.26459500193595886, 6.288437366485596], [31.309999465942383, -57.3125, 26.5, -4.0, 0.2652359902858734, -6.100625038146973], [31.309999465942383, -49.1875, 6.1875, -40.625, 0.26203250885009766, -57.60593795776367], [31.329999923706055, -47.5, 14.0625, -43.5, 0.2575474977493286, -45.93375015258789], [31.329999923706055, -44.6875, 9.5625, -44.0, 0.2549850046634674, -0.8025000095367432], [31.290000915527344, -44.4375, 11.625, -45.625, 0.25434449315071106, 70.50405883789062], [31.290000915527344, -43.9375, 11.25, -46.0, 0.25306299328804016, 40.780311584472656], [31.290000915527344, -43.25, 10.5625, -46.625, 0.2537040114402771, 9.294687271118164], [31.290000915527344, -44.1875, 9.8125, -46.0625, 0.25178149342536926, -3.7284374237060547], [31.290000915527344, -43.875, 9.5, -46.25, 0.25306299328804016, 42.3415641784668], [31.290000915527344, -43.625, 9.125, -46.8125, 0.2524225115776062, -4.95968770980835], [31.309999465942383, -43.3125, 8.25, -46.8125, 0.2549850046634674, -5.583125114440918], [31.309999465942383, -43.25, 9.0625, -47.0625, 0.25562548637390137, -9.16031265258789], [31.309999465942383, -43.5, 8.9375, -46.625, 0.2511410117149353, 3.1287500858306885], [31.309999465942383, -43.5625, 8.3125, -47.0, 0.25178149342536926, -1.0709375143051147], [31.309999465942383, -43.5, 8.25, -46.6875, 0.25178149342536926, -2.858750104904175], [31.309999465942383, -42.875, 7.9375, -47.1875, 0.2524220049381256, 4.485312461853027], [31.309999465942383, -41.0, 8.75, -48.625, 0.25178149342536926, -4.865312576293945], [31.309999465942383, -41.3125, 9.1875, -48.3125, 0.2511410117149353, -4.489062309265137], [31.270000457763672, -41.5, 8.875, -48.5, 0.25178149342536926, -2.4175000190734863], [31.270000457763672, -41.8125, 9.0625, -47.875, 0.2524220049381256, -2.541562557220459], [31.309999465942383, -41.9375, 9.25, -47.8125, 0.2498594969511032, 17.454687118530273], [31.309999465942383, -44.75, 8.0, -45.4375, 0.25050050020217896, -3.1965625286102295], [31.290000915527344, -47.375, 6.125, -43.1875, 0.25050050020217896, -7.521874904632568], [31.290000915527344, -46.25, 6.3125, -44.375, 0.2498600035905838, -2.835624933242798], [31.329999923706055, -43.8125, 6.5, -46.8125, 0.2498600035905838, 6.659999847412109], [31.329999923706055, -42.8125, 7.0, -47.5625, 0.24921900033950806, -5.659999847412109], [31.290000915527344, -48.125, 6.8125, -41.0, 0.25050050020217896, 12.0365629196167], [31.290000915527344, -45.5, 6.5625, -45.5625, 0.24921900033950806, -12.514062881469727], [31.309999465942383, -45.0625, 6.625, -45.1875, 0.24921900033950806, 0.4078125059604645], [31.309999465942383, -45.375, 6.8125, -45.3125, 0.24921900033950806, 0.07656250149011612], [31.309999465942383, -45.4375, 6.875, -44.9375, 0.24921900033950806, -12.87093734741211], [31.309999465942383, -45.8125, 7.0625, -44.875, 0.2485779970884323, 0.47593748569488525], [31.329999923706055, -47.3125, 7.3125, -42.5, 0.24921900033950806, 0.8662499785423279], [31.329999923706055, -45.125, 6.6875, -45.5, 0.24793750047683716, -0.8531249761581421], [31.329999923706055, -46.5625, 6.1875, -43.8125, 0.24793750047683716, 4.263750076293945], [31.329999923706055, -49.1875, 6.0625, -40.5, 0.24665650725364685, -26.233125686645508], [31.309999465942383, -46.4375, 6.0625, -44.5, 0.24665650725364685, 28.895313262939453], [31.309999465942383, -45.9375, 6.0, -44.875, 0.24793750047683716, -7.016562461853027], [31.309999465942383, -47.75, 6.6875, -41.8125, 0.24665650725364685, 4.136562347412109], [31.309999465942383, -59.3125, 7.75, -34.375, 0.247297003865242, -2.899062395095825], [31.309999465942383, -56.75, -17.3125, -1.8125, 0.247297003865242, -1.3309375047683716], [31.309999465942383, -12.0625, -54.625, 33.875, 0.2485785037279129, 64.94437408447266], [31.329999923706055, -28.1875, -51.5625, 11.25, 0.2460159957408905, 68.7768783569336], [31.329999923706055, -20.0, -57.75, 22.25, 0.2447340041399002, -89.0434341430664], [31.329999923706055, -17.375, -58.9375, 21.6875, 0.24281249940395355, -166.9656219482422], [31.329999923706055, -16.5, -58.5625, 20.375, 0.24153099954128265, 83.86312866210938], [31.309999465942383, -14.1875, -56.0, 21.9375, 0.2421720027923584, 27.453125], [31.309999465942383, -52.125, -21.6875, 8.5, 0.2408899962902069, -5.574687480926514], [31.329999923706055, -67.375, 2.0, -0.9375, 0.2421720027923584, -18.73031234741211], [31.329999923706055, -64.875, 2.0625, -7.3125, 0.2408899962902069, 9.527812957763672], [31.309999465942383, -63.5625, 0.8125, -6.6875, 0.24024949967861176, 13.158437728881836], [31.309999465942383, -63.8125, 1.875, -13.125, 0.2408905029296875, -28.43000030517578], [31.309999465942383, -63.625, 1.9375, -13.125, 0.2396090030670166, 3.932499885559082], [31.309999465942383, -63.875, 2.25, -12.1875, 0.24024949967861176, -8.2759370803833], [31.309999465942383, -63.6875, 2.1875, -11.6875, 0.2408905029296875, 14.36343765258789], [31.309999465942383, -63.6875, 1.75, -10.8125, 0.24024949967861176, 15.329999923706055], [31.309999465942383, -64.125, 2.4375, -10.3125, 0.24025000631809235, 5.5], [31.309999465942383, -64.0, 2.0, -11.3125, 0.2396090030670166, 4.882187366485596], [31.329999923706055, -63.6875, 1.75, -11.25, 0.24024949967861176, 3.645937442779541], [31.329999923706055, -63.75, 1.6875, -11.5625, 0.24153099954128265, 0.9703124761581421], [31.309999465942383, -63.625, 1.9375, -11.75, 0.2408899962902069, 4.468124866485596], [31.309999465942383, -63.75, 1.1875, -12.125, 0.2396090030670166, 7.339375019073486], [31.309999465942383, -64.0, 0.8125, -12.75, 0.24024949967861176, -8.634062767028809], [31.309999465942383, -63.5, 1.25, -11.875, 0.24024949967861176, -2.111562490463257], [31.329999923706055, -64.0625, 1.25, -12.125, 0.24024949967861176, -3.908750057220459], [31.329999923706055, -63.9375, 1.0, -10.8125, 0.24153099954128265, -19.283124923706055], [31.329999923706055, -64.625, 1.0625, -3.25, 0.2396090030670166, 18.185312271118164], [31.329999923706055, -64.875, 0.6875, -4.6875, 0.2408899962902069, 13.4399995803833], [31.329999923706055, -65.125, 0.375, -4.4375, 0.2396090030670166, -6.268437385559082], [31.329999923706055, -64.0, 0.0, 2.75, 0.24024949967861176, -1.8350000381469727], [31.329999923706055, -64.5, 0.9375, -8.875, 0.24153099954128265, -5.253437519073486], [31.329999923706055, -63.125, 1.3125, -14.875, 0.24153099954128265, 80.84468841552734], [31.329999923706055, -62.6875, -1.0, -17.0625, 0.2408899962902069, -60.643436431884766], [31.329999923706055, -63.6875, -1.3125, -14.375, 0.24153099954128265, -39.541873931884766], [31.309999465942383, -64.1875, 9.5625, -9.5, 0.2408899962902069, -15.694687843322754], [31.309999465942383, -60.125, 24.0625, 3.875, 0.2421720027923584, 102.00718688964844], [31.290000915527344, -63.3125, 17.3125, 4.75, 0.2421714961528778, -54.362186431884766], [31.290000915527344, -59.9375, 9.9375, -12.0, 0.2408899962902069, 6.955937385559082], [31.309999465942383, -33.3125, 53.25, -14.375, 0.24153099954128265, -17.779687881469727], [31.309999465942383, 14.125, 56.0625, 22.375, 0.2396090030670166, 12.828749656677246], [31.309999465942383, 19.25, 57.125, 20.5, 0.2421714961528778, -44.96937561035156], [31.309999465942383, 4.25, 63.0, 18.625, 0.2421720027923584, 91.0434341430664], [31.329999923706055, -33.3125, 57.4375, -2.9375, 0.24153099954128265, -98.43468475341797], [31.329999923706055, -29.1875, 60.875, 10.5625, 0.2421720027923584, 154.6671905517578], [31.329999923706055, -25.3125, 63.5, 22.9375, 0.2421720027923584, -245.53875732421875], [31.329999923706055, -7.875, 63.3125, 1.875, 0.2421720027923584, 28.7784366607666], [31.329999923706055, -12.25, 60.9375, 17.375, 0.24281249940395355, 85.06812286376953], [31.329999923706055, -14.0, 65.1875, 6.1875, 0.2434529960155487, 78.80687713623047], [31.329999923706055, 6.4375, 65.1875, 18.625, 0.24409349262714386, 20.073749542236328]]];
    var output = List(1 * 1).reshape([1, 1]);
    interpreter.run(input, output);

    if (output[0][0] >= 0.148 && (counter_true < 5 && counter_false < 3)){
      counter_true += 1;
      counter_false = 0;
    }
    else if(output[0][0] >= 0.148 && (counter_true < 5 && counter_false == 3)){
      counter_true += 1;
      if (counter_true == 5){
        counter_false = 0;
      }
    }
    else if(output[0][0] >=  0.148 && (counter_true == 5 && counter_false < 3)){
      counter_false = 0;
    }
    else if (output[0][0] <  0.148 && (counter_true < 5 && counter_false < 3)){
      counter_false += 1 ;
      counter_true = 0;
    }
    else if(output[0][0] <  0.148 && (counter_true < 5 && counter_false == 3)){
      counter_true = 0;
    }
    else if(output[0][0] <  0.148 && (counter_true == 5 && counter_false < 3)){
      counter_false +=1;
      if (counter_false == 3 ){
        counter_true = 0;
      }
    }
   // prediction = output[0][0];
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

  void _normalize(data) {
    data.acc = (data.acc - _Constants.accMin) / _Constants.accRange;
    data.bvp = (data.bvp - _Constants.bvpMin) / _Constants.bvpRange;
    data.eda = (data.eda - _Constants.edaMin) / _Constants.edaRange;
    data.temp = (data.temp - _Constants.tempMin) / _Constants.tempRange;
  }

  void _loadModel() async {
    switch(userName) {
      case "Ahmet Şentürk":
        interpreter = await Interpreter.fromAsset('big_dataset_ahmet_senturk.tflite');
        break;

      case "Ahmet Yiğit Gedik":
        interpreter = await Interpreter.fromAsset('big_dataset_ahmet_gedik_best.tflite');
        break;

      case "Yaşar Selçuk Çalışkan":
        interpreter = await Interpreter.fromAsset('big_dataset_yasar.tflite');
        break;

      case "":
        print("Chosen Person is blank.");
        break;
    }
  }
}
