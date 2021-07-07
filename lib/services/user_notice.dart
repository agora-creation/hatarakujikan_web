import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

const String serverUrl = 'https://fcm.googleapis.com/fcm/send';
const String serverKey =
    'AAAAZNHaT_E:APA91bH9VRe1rNTG5aXLLEOltYAtMwzK5PEoQPCsiusrzcRtTOdRx3KSZ27dOYcwnSjfpz7d0_S9KAAVSDUuyuARZHnpQD_jBqOZ2sIlXLhTQQ5QdyPbiLdAMPL91Y3CCudCJSEkkR6w';

class UserNoticeService {
  String _collection = 'user';
  String _subCollection = 'notice';
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void create(Map<String, dynamic> values) {
    _firebaseFirestore
        .collection(_collection)
        .doc(values['userId'])
        .collection(_subCollection)
        .doc(values['id'])
        .set(values);
  }

  void send({String token, String title, String body}) {
    try {
      http.post(
        Uri.parse(serverUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'priority': 'high',
          'notification': {
            'title': title,
            'body': body,
          },
        }),
      );
    } catch (e) {
      print(e.toString());
    }
  }
}
