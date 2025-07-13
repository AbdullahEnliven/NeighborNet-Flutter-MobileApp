import 'dart:convert';
import 'package:http/http.dart' as http;

import 'get_server_key.dart';

class SendNotification {
  static Future<void> sendPushNotification({
    required String fcmToken,
    required String title,
    required String message,
  }) async {
    final getServerkey = get_server_key();
    String accesstoken = await getServerkey.get_server_key_token();
    String serverKey = accesstoken;

    await http.post(
      Uri.parse(
        'https://fcm.googleapis.com/v1/projects/neighbournet-bd503/messages:send',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(<String, dynamic>{
        "message": {
          "token": fcmToken,
          "notification": {"body": message, "title": title},
        },
      }),
    );
  }
}
