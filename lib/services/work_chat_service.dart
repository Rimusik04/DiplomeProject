import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {

  static Future<String> createChat(String user1, String user2) async {

    final chat = await FirebaseFirestore.instance
        .collection('chats')
        .add({
      "participants": [user1, user2],
      "createdAt": Timestamp.now(),
    });

    return chat.id;
  }

}