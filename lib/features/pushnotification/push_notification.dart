import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// ignore: camel_case_types
class pushnotification {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//static final MessagingController messagingController = Get.find<MessagingController>();

  Future init() async {
    await requestpermissions();
    await localNotiInit();
    FirebaseMessaging.onMessage.listen(handleIncomingMessage);
  }
   static Future<void> requestpermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );}
  static Future localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    String? payload = notificationResponse.payload; // Get the payload

    if (payload != null && payload.isNotEmpty) {
      // App opens and navigates to a specific page based on payload
      // nevegatorkey.currentState!.pushNamed(
      //   "homepage",
      // );
    } else {
      
      return;
    }
  }

  static void handleIncomingMessage(RemoteMessage message) {
    // Check if the user is actively viewing the chat screen
  //  / if (messagingController.isActiveChat.value) {
  //     // User is actively chatting, do not show notification
  //     return;
  //   }

    // Show notification if the user is not actively chatting
    showSimpleNotification(
        body: message.notification?.body ?? '',
        title: message.notification?.title ?? '',
        payload: null);
  }

  // show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload ?? '');
  }
}
