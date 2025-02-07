import 'dart:async';
import 'package:flutter/material.dart';
import 'package:termostato/term_list_view_dialog.dart';
import 'package:termostato/termostato.dart';
import 'package:thermostat/thermostat.dart';

class TermostatoView extends StatefulWidget {
  final String url;
  final String user;
  final String psw;
  final String name;
  const TermostatoView({required this.name, required this.url, required this.user, required this.psw, super.key});

  @override
  State<TermostatoView> createState() => _TermostatoViewState();
}

class _TermostatoViewState extends State<TermostatoView> {

  bool power = false;
  double temperature = 0.0;
  double setPoint = 22.5;
  double minSetPoint = 15;
  double maxSetPoint = 30;
  String warningNoTemperature = "";
  Color colorPowerState = Colors.white;
  late Termostato term1;
  late StreamSubscription listenTemperature;
  late StreamSubscription listenSetpoint;
  

  @override
  void initState(){
    super.initState();
    term1 = Termostato(url: widget.url, user: widget.user, key: widget.psw);
    listenSetpoint = term1.onNewSetPoint.listen((event) {
      setPoint = event; //event = onNewSetPoint()
      setState(() {});
    });
    listenTemperature = term1.mqttClientApp.onNewTemp.listen((temp) {
      temperature = temp;
      warningNoTemperature = "";
      setState(() {});
    });
  }

  void stopListen () {
    //cancel
    listenSetpoint.cancel();
    listenTemperature.cancel();
  }

  @override
  Widget build(BuildContext context) {

    late SetPointMode mySetpointMode;
    if (power) {
      mySetpointMode = SetPointMode.displayAndEdit;
    } else {
      mySetpointMode = SetPointMode.notDisplay;
      setPoint = temperature;
    }

    return Scaffold(
      appBar: AppBar(
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(child: Text("TERMOSTATO di ${widget.name}")),
            TextButton(
              child: const Icon(Icons.change_circle_outlined),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (_) => TermListViewDialog()
                ).then((value) {
                  if(value != null){
                    stopListen();
                  }
                });
              }, 
            ),
          ],
        ),
        foregroundColor: Colors.deepPurpleAccent,
        backgroundColor: Colors.black,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Thermostat(
              maxVal: maxSetPoint,
              minVal: minSetPoint,
              curVal: temperature ,
              setPoint: setPoint,
              setPointMode: mySetpointMode,
              turnOn: power,

              themeType: ThermostatThemeType.dark,
              theme: ThermostatTheme.light(
                dividerColor: Colors.deepPurpleAccent,
                glowColor: Colors.deepPurpleAccent,
                turnOnColor: Colors.deepPurpleAccent,
                thumbColor: setThumbColor,
                tickColor: Colors.deepPurpleAccent,
                ),

              onChanged: (setPoint) {
                setPoint = (setPoint * 100).roundToDouble() / 100;
                if (power) {
                  if (term1.state) {  //caldo
                    if (setPoint > temperature) {
                      term1.setSetPoint(setPoint);
                    } else {
                      term1.setSetPoint(temperature);
                    }
                  } else { //freddo
                    if (setPoint < temperature) {
                      term1.setSetPoint(setPoint);
                    } else {
                      term1.setSetPoint(temperature);
                    }
                  }
                }
              },
              
            ),
          ),
        ],
      ),

      bottomNavigationBar:  Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 30, left: 30, right: 30,),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            //const SizedBox(width: 10),

            FloatingActionButton(
              heroTag: "warm_cold",
              onPressed: () {
                setState(() {
                  term1.state = !term1.state;
                  if (power) {
                    term1.setSetPoint(temperature);
                    if (term1.state) {
                      colorPowerState = const Color.fromARGB(255, 255, 83, 83);
                    } else {
                      colorPowerState = const Color.fromARGB(255, 63, 252, 255);
                    }
                  }
                });
              },
              backgroundColor: colorPowerState,
              child: term1.state ? const Icon(Icons.local_fire_department) : const Icon(Icons.ac_unit),
            ),

            Text(warningNoTemperature),

            FloatingActionButton(
              heroTag: "connectionStatus",
              onPressed: () {
                setState(() {
                  if (temperature != 0.0) {
                    power = !power;
                    if (power) {
                      if (term1.state) {
                        colorPowerState = const Color.fromARGB(255, 255, 83, 83);
                      } else {
                        colorPowerState = const Color.fromARGB(255, 63, 252, 255);
                      }
                    } else {
                      colorPowerState = Colors.white;
                    }
                  } else {
                    warningNoTemperature = "Wait Temperature";
                    term1.setSetPoint(100.0);
                  }
                });
              },
              backgroundColor: colorPowerState,
              child: const Icon(Icons.power_settings_new),
            ),
          ],
        ),
      ),
    );
  }

  Color get setThumbColor {
    if (!term1.state) {
      if (setPoint >= temperature) {
        return (const Color.fromARGB(255, 255, 17, 0));
      } else {
        return (Colors.deepPurple);
      }
    } else {
      if (setPoint <= temperature) {
        return (const Color.fromARGB(255, 0, 191, 255));
      } else {
        return (Colors.deepPurple);
      }
    } 
  }

  @override
  void dispose() {
    super.dispose();
    stopListen();
  }
}
