import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize('resource://drawable/notification_icon', [
    // notification icon
    NotificationChannel(
      channelGroupKey: 'basic_test',
      channelKey: 'basic',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      channelShowBadge: true,
      importance: NotificationImportance.High,
    ),

    //add more notification type with different configuration
  ]);

  //tap listiner on notification
  AwesomeNotifications()
      .actionStream
      .listen((ReceivedNotification receivedNotification) {
    print(receivedNotification.payload['name']);
    //output from first notification:  FlutterCampus
  });
  runApp(SensorNotification());
}

class SensorNotification extends StatefulWidget {
  @override
  _SensorNotificationState createState() => _SensorNotificationState();
}

class _SensorNotificationState extends State<SensorNotification> {
  bool _isNear = false;
  StreamSubscription<dynamic> _streamSubscription;

  notification() async {
    bool isallowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isallowed) {
      //no permission of local notification
      AwesomeNotifications().requestPermissionToSendNotifications();
    } else {
      //show notification
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              //simgple notification
              id: 123,
              channelKey: 'basic', //set configuration wuth key "basic"
              title: 'Welcome to FlutterCampus.com',
              body: 'This simple notification is from Flutter App',
              payload: {"name": "FlutterCampus"}));
    }
  }

  @override
  void initState() {
    super.initState();
    listenSensor();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  Future<void> listenSensor() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (foundation.kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    _streamSubscription = ProximitySensor.events.listen((int event) {
      setState(() {
        _isNear = (event > 0) ? true : false;
        print(_isNear);
        //_isNear = true;
        if (_isNear == true) {
          Vibration.vibrate(
            duration: 1000,
            amplitude: 100,
          );
          notification();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sensor/Notificação mobile2'),
        ),
        body: Center(
          child: Text(
              'Está perto? ${(_isNear == true ? 'sim(notificado)' : 'não')}'),
        ),
      ),
    );
  }
}
