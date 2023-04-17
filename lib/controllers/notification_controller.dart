import 'dart:convert';
import 'dart:developer';
import 'package:fcm_task/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  onInit() {
    super.onInit();
    requestPermission();
    // loadFCM();
    onMessage();
    onMessageClick();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      log('User declined or has not accepted permission');
    }
  }

  onMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("this ${message.data['click_action']}");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
      if (message.data['click_action'] == 'welcome') {
        log("this is the ${message.data.toString()}");
        Get.toNamed(Routes.welcome);
      }
    });
  }

  onMessageClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("this is the ${message.data['click_action']}");
      if (message.data['click_action'] == 'welcome') {
        Get.toNamed(Routes.welcome);
      }
    });
  }

  // void loadFCM() async {
  //   channel = const AndroidNotificationChannel(
  //     'high_importance_channel', // id
  //     'High Importance Notifications', // title
  //     importance: Importance.high,
  //     enableVibration: true,
  //   );

  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   await flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(channel);
  //   await FirebaseMessaging.instance
  //       .setForegroundNotificationPresentationOptions(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  // }

  sendPushMessage(String token, String body, String title) async {
    log('this is calling ');
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAE_0uuoE:APA91bE5NsJMqk2_kZJstBzkA3MugUqm2o1aaZgcJo67vnX0pU-YS1TXnKa2NZrbd-zESuksgomcOVDHbfl3sziyO1NOiYLncZAvTL6eQ_CwSUB136v_JaJ_sDt-PclgCB87od73RO2L',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'imageUrl': 'assets/logo.png',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'welcome',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      log("error push notification");
    }
  }
}
