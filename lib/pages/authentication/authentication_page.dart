import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Authentication_Page extends StatefulWidget {

  final String chosenPerson;

  Authentication_Page({Key key, @required this.chosenPerson}) : super(key: key);

  @override
  _Authentication_PageState createState() => _Authentication_PageState();
}

class _Authentication_PageState extends State<Authentication_Page> {

  int _connectionStatus = 1;

  List<String> _connectionStatusTextList = <String> [
    "Please wait 3 minutes for authentication",
    "You have entered the system successfully"
  ];
  List<Color> _connectionIconColorList = <Color>[
    Colors.red,
    Colors.green
  ];
  List<IconData> _statusIconsList = <IconData>[
    Icons.lock,
    Icons.lock_open
  ];
  List<bool> _spinnerVisibility = <bool>[
    true,
    false
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Authentication Page"),
        backgroundColor: _connectionIconColorList[_connectionStatus],
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
                      color: _connectionIconColorList[_connectionStatus],
                      fontSize: 24,
                      fontWeight: FontWeight.w300
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 48),
              child: Text(
                _connectionStatusTextList[_connectionStatus],
                style: TextStyle(
                    color: _connectionIconColorList[_connectionStatus],
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 36),
              child: Visibility(
                visible: _spinnerVisibility[_connectionStatus],
                child: SpinKitCircle(
                  color: Colors.deepOrange,
                  size: 75.0,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 100),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Icon(
                    _statusIconsList[_connectionStatus],
                    color: _connectionIconColorList[_connectionStatus],
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
                      primary: _connectionIconColorList[_connectionStatus]
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
                    Toast.show("Changing context", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
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
  }
}