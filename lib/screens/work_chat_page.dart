import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? replyTo;

  Future sendMessage({String? imageUrl}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (messageController.text.trim().isEmpty && imageUrl == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      "text": messageController.text.trim(),
      "imageUrl": imageUrl,
      "senderId": user.uid,
      "replyTo": replyTo,
      "createdAt": Timestamp.now(),
    });

    messageController.clear();
    setState(() => replyTo = null);
  }

  Future pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    sendMessage(imageUrl: picked.path);
  }

  String formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      appBar: AppBar(
        title: const Text("Chat"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          if (replyTo != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(child: Text("Ответ: $replyTo")),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => replyTo = null),
                  )
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg["senderId"] == user!.uid;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: _buildMessage(msg, isMe),
                    );
                  },
                );
              },
            ),
          ),

          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(QueryDocumentSnapshot msg, bool isMe) {
    final text = msg["text"];
    final imageUrl = msg["imageUrl"];
    final time = formatTime(msg["createdAt"]);

    return GestureDetector(
      onHorizontalDragEnd: (_) {
        setState(() => replyTo = text);
      },

      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,

        children: [

          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg["replyTo"] != null)
                    Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        msg["replyTo"],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  if (imageUrl != null && imageUrl != "")
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(imageUrl),
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (text != "")
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.white,

        child: Row(
          children: [

            IconButton(
              icon: const Icon(Icons.image),
              onPressed: pickImage,
            ),

            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Voice coming soon")),
                );
              },
            ),

            Expanded(
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: "Сообщение...",
                  border: InputBorder.none,
                ),
              ),
            ),

            /// отправка
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => sendMessage(),
            ),
          ],
        ),
      ),
    );
  }
}