import 'package:flutter/material.dart';
import 'package:ppg_authentication/pages/authentication/authentication_page.dart';
import 'package:toast/toast.dart';
import 'package:get/get.dart';
import 'package:ppg_authentication/services/empatica.dart';


import '../../controllers/classification.dart';

class HomePage extends StatefulWidget {

  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _chosenPerson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          GetBuilder<EmpaticaService>(
            builder: (ctrlr) => ctrlr.bandConnectedNonStatic
                ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.watch_rounded,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            )
                : Container(),
          ),
        ],
      ),
      body: Center(
        child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 100, bottom: 50),
                child: Image.asset(
                    'assets/images/logo.png'
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 50),
                child: DropdownButton<String>(
                  value: _chosenPerson,
                  elevation: 5,
                  style: TextStyle(
                      color: Colors.black87
                  ),
                  items: <String>[
                    'Ahmet Şentürk',
                    'Ahmet Yiğit Gedik',
                    'Yaşar Selçuk Çalışkan',
                    'Ömer Şentürk',
                    'Deren Olağan',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text(
                    "Please choose who you are",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _chosenPerson = value;
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 0),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrange
                    ),
                    child: Text(
                      "Continue",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    onPressed: () {
                      if (_chosenPerson == null || _chosenPerson.isEmpty) {
                        Toast.show("Please choose who you are", context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER);
                      }
                      else if (!EmpaticaService.bandConnected) {
                        Toast.show("Please connect an E4 device", context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER);
                      }
                      else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Authentication_Page(chosenPerson: this._chosenPerson))
                        );
                        ClassificationCtrlr.authenticationState = true;
                      }
                    },
                  ),
                ),
              )
            ]
        ),
      ),
    );
  }
}
