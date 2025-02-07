import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientApp {
  final String _url;
  final String _user;
  final String _key;
  bool _connectionStatus = true;
  late MqttServerClient _client;

  var pongCount = 0;

  MQTTClientApp(this._url,this._user,this._key) {
    _client = MqttServerClient(_url, '');
    start();
  }
  
  //////////////////////////////////////////////////////////////////////////
  // CREO l'EVENTO newTemp
  StreamController tempController =StreamController.broadcast();
  void _notifyNewTemp(double temp) {
    tempController.add(temp);
  }
  Stream get onNewTemp => tempController.stream;
  //////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  // CREO l'EVENTO newSetPoint
  StreamController setPointController =StreamController.broadcast();
  void _notifyNewsetPoint(double setPoint) {
    setPointController.add(setPoint);
  }
  Stream get onNewSetPoint => setPointController.stream;
  //////////////////////////////////////////////////////////////////////////
    
  Future<void> start() async {
    await connect();
    listenEvents();
    listenTemperatures();
    listenSetPoint();
  }

  Future<void> connect() async {
    _client.logging(on: true);
    _client.setProtocolV311();
    _client.keepAlivePeriod = 20;
    _client.connectTimeoutPeriod = 2000;
    _client.onDisconnected = onDisconnected;
    _client.onConnected = onConnected;
    _client.onSubscribed = onSubscribed;
    _client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .authenticateAs(_user, _key)
        .withClientIdentifier('connessioneMQTT')
        .withWillMessage("START")
        .withWillTopic('$_user/feeds/connections')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    debugPrint('AdaFruit client connecting....');
    _client.connectionMessage = connMess;
    
    try {
      await _client.connect();
    } on NoConnectionException catch (e) {
      debugPrint('client exception - $e');
      _client.disconnect();
    } on SocketException catch (e) {
      debugPrint('socket exception - $e');
      _client.disconnect();
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('AdaFruit client connected');
    } else {
      debugPrint(
          'ERROR AdaFruit client connection failed - disconnecting, status is ${_client.connectionStatus}');
      _client.disconnect();
    }
  }

  void disconnect() {
    debugPrint('Disconnecting...');
    _client.disconnect();
  }

  void publish(String message) {
    String pubTopic = '$_user/feeds/setPoints';
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      _connectionStatus = true;
      _client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);
      debugPrint('Publish::The message has been published');
    } else {
      if (_client.connectionStatus!.state != MqttConnectionState.connected) {
        _connectionStatus = false;
        debugPrint('Publish::Not connected to the MQTT server. Retrying...');
        connect();
      } else {
        _connectionStatus = true;
        _client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);
        debugPrint('Publish::The message has been published AFTER ONE TENTATIVE');
      }
    }
  }

  bool giveConnectionState () {
    return _connectionStatus;
  }

  void listenEvents() {
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage receivedMessage = messages[0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
      
      double? value = double.tryParse(message);
      if(messages[0].topic == '$_user/feeds/temperatures') {
        if(value != null) {
          _notifyNewTemp(value);
        } else {
          debugPrint('ERROR: Received message not double');
        }
      } else if(messages[0].topic == '$_user/feeds/setPoints') {
        if(value != null) {
          _notifyNewsetPoint(value);
        } else {
          debugPrint('ERROR: Received message not double');
        }
      }
      
      debugPrint('Received message: $message');
    });
  }

  void listenTemperatures() {
    String subTopic = "$_user/feeds/temperatures";
    _client.subscribe(subTopic, MqttQos.atMostOnce);
  }
  void listenSetPoint() {
    String subTopic = "$_user/feeds/setPoints";
    _client.subscribe(subTopic, MqttQos.atMostOnce);
  }

  void onSubscribed(String topic) {
    debugPrint('Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    debugPrint('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      debugPrint('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      debugPrint('EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
    }
    if (pongCount == 3) {
      debugPrint('EXAMPLE:: Pong count is correct');
    } else {
      debugPrint('EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  void onConnected() {
    debugPrint(
        'EXAMPLE::OnConnected client callback - Client connection was successful');
  }

  void pong() {
    debugPrint('EXAMPLE::Ping response client callback invoked');
    pongCount++;
  }
}