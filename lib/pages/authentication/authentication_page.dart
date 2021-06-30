import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ppg_authentication/controllers/classification.dart';
import 'package:get/get.dart';

import '../../controllers/classification.dart';

class Authentication_Page extends StatefulWidget {

  final String chosenPerson;

  Authentication_Page({Key key, @required this.chosenPerson}) : super(key: key);

  @override
  _Authentication_PageState createState() => _Authentication_PageState();
}

class _Authentication_PageState extends State<Authentication_Page> {

  List<bool> _welcomeTextVisibility = <bool> [
    false,
    true,
    false,
    false
  ];

  List<String> _connectionStatusTextList = <String> [
    "Authenticating",
    "You are authenticated successfully",
    "Authentication failed",
    "Empatica E4 is not on wrist"
  ];

  List<String> _connectionStatusSubtextList = <String> [
    "",
    "",
    "Please hold still for authentication",
    "Please have your watch on your wrist"
  ];

  List<Color> _connectionIconColorList = <Color>[
    Colors.deepOrange,
    Colors.green,
    Colors.red,
    Colors.red
  ];
  List<IconData> _statusIconsList = <IconData>[
    Icons.lock,
    Icons.lock_open,
    Icons.lock,
    Icons.error_outline
  ];
  List<bool> _spinnerVisibility = <bool>[
    true,
    false,
    true,
    false
  ];

  Future<bool> _onWillPopAuthenticationPage() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to abandon authentication?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              ClassificationCtrlr.to.setAuthenticationState(false);
              },
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassificationCtrlr>(builder: (ctrlr) {
      int prediction = ctrlr.prediction;
      ClassificationCtrlr.userName = widget.chosenPerson;
      ClassificationCtrlr.to.loadModel();
      return WillPopScope(
          child: Scaffold(
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
                      child: Visibility(
                        visible: _welcomeTextVisibility[ctrlr.prediction],
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
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 48),
                    child: Text(
                      _connectionStatusTextList[ctrlr.prediction],
                      style: TextStyle(
                          color: _connectionIconColorList[ctrlr.prediction],
                          fontSize: 18,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Text(
                      _connectionStatusSubtextList[ctrlr.prediction],
                      style: TextStyle(
                          color: _connectionIconColorList[ctrlr.prediction],
                          fontSize: 14,
                          fontWeight: FontWeight.w400
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
                ],
              ),
            ),
          ),
          onWillPop: _onWillPopAuthenticationPage
      );
    });

  }
}