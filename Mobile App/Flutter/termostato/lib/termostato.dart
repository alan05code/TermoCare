import 'dart:async';
import 'mqtt.dart';

class Termostato {
  bool state = true; //warm/cold
  double _setPoint = 22.5;

  final String url;
  final String user;
  final String key;

  late MQTTClientApp mqttClientApp;
  Termostato({required this.url,required this.user,required this.key}) {
    mqttClientApp = MQTTClientApp(url,user,key);
    listenMQTTEvent();
  }

  void listenMQTTEvent () {
    mqttClientApp.onNewTemp.listen((event) {
      _notifyNewTemp(event);
    });
    mqttClientApp.onNewSetPoint.listen((event) {
      _notifyNewSetPoint(event);
    });
  }

  //////////////////////////////////////////////////////////////////////////
  // CREO l'EVENTO newTemp
  StreamController tempController =StreamController.broadcast();
  void _notifyNewTemp(double temp) {
    tempController.add(temp);
  }
  Stream get onNewTemp => tempController.stream;
  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////
  // CREO l'EVENTO _setPoint
  StreamController setPointController =StreamController.broadcast();
  void _notifyNewSetPoint(double setPoint) {
    _setPoint = setPoint;
    setPointController.add(_setPoint);
  }
  Stream get onNewSetPoint => setPointController.stream;
  //////////////////////////////////////////////////////////////////////////
  
  void setSetPoint(double setPoint) {
    mqttClientApp.publish(setPoint.toString());
  }

  bool updateConnectionState () {
    return mqttClientApp.giveConnectionState();
  }
}