import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:stress_detector/controllers/classification.dart';
import 'package:get/get.dart';

class Authentication_Page extends StatefulWidget {

  final String chosenPerson;

  Authentication_Page({Key key, @required this.chosenPerson}) : super(key: key);

  @override
  _Authentication_PageState createState() => _Authentication_PageState();
}

class _Authentication_PageState extends State<Authentication_Page> {
  int _connectionStatus = 1;

  List<String> _connectionStatusTextList = <String> [
    "Please wait 30 seconds for authentication",
    "You are authenticated successfully",
    "Authentication failed"
  ];
  List<Color> _connectionIconColorList = <Color>[
    Colors.deepOrange,
    Colors.green,
    Colors.red
  ];
  List<IconData> _statusIconsList = <IconData>[
    Icons.lock,
    Icons.lock_open,
    Icons.lock
  ];
  List<bool> _spinnerVisibility = <bool>[
    true,
    false,
    true
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassificationCtrlr>(builder: (ctrlr) {
      int prediction = ctrlr.prediction;
      return Scaffold(
        appBar: AppBar(
          title: Text("Authentication Page"),
          backgroundColor: _connectionIconColorList[ctrlr.prediction],
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 16, top: 36),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Welcome, " + widget.chosenPerson,
                    style: TextStyle(
                        color: _connectionIconColorList[ctrlr.prediction],
                        fontSize: 24,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 48),
                child: Text(
                  _connectionStatusTextList[ctrlr.prediction],
                  style: TextStyle(
                      color: _connectionIconColorList[ctrlr.prediction],
                      fontSize: 18,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 36),
                child: Visibility(
                  visible: _spinnerVisibility[ctrlr.prediction],
                  child: SpinKitCircle(
                    color: _connectionIconColorList[ctrlr.prediction],
                    size: 75.0,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 100),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(
                      _statusIconsList[ctrlr.prediction],
                      color: _connectionIconColorList[ctrlr.prediction],
                      size: 150
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: _connectionIconColorList[ctrlr.prediction]
                    ),
                    child: Text(
                      "CHANGE",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                    onPressed: () {
                      Toast.show("Changing context" , context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                      setState(() {
                        _connectionStatus = (_connectionStatus + 1) % 2;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

  }
}