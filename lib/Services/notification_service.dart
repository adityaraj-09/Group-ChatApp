import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:insien_flutter/Services/database_service.dart';

class NotificationService{

  FirebaseMessaging messaging=FirebaseMessaging.instance;
  void requestNotification()async{
    NotificationSettings settings=await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){

    }else if(settings.authorizationStatus==AuthorizationStatus.provisional){

    }else{
      AppSettings.openNotificationSettings();
    }
  }

  final FlutterLocalNotificationsPlugin notificationsPlugin=FlutterLocalNotificationsPlugin();
  void initLocalN(BuildContext context,RemoteMessage message) async{
    var androidInitializationSettings=const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings=const DarwinInitializationSettings();
    var initilizationSetting=InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings
    );
    await notificationsPlugin.initialize(initilizationSetting,
    onDidReceiveNotificationResponse:(payload){

    });
  }

  void firebaseInit(){
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message)async {
    AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        "insien",
        importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        androidNotificationChannel.id.toString(),
        androidNotificationChannel.name.toString(),
        channelDescription: "New messages",
        importance: Importance.high,
        priority: Priority.high,
        ticker: "ticker");
    NotificationDetails details=NotificationDetails(
      android: androidNotificationDetails,
    );
    Future.delayed(Duration.zero, () {
      notificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          details);
    }

    );
  }

  Future<String> token()async{
   String? token=await messaging.getToken();
    return token!;
  }

  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      Database(uid: FirebaseAuth.instance.currentUser!.uid).savingToken(event.toString());
    });
  }

}