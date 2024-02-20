import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatelessWidget {
  final String chatDocumentId;
  final String name;

  const ChatPage({Key? key, required this.chatDocumentId, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messaging',
          style: GoogleFonts.poppins(letterSpacing: 0.5),
        ),
        backgroundColor: Colors.cyan,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ChatScreen(chatDocumentId: chatDocumentId,name: name),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String chatDocumentId;
  final String name;

  const ChatScreen({Key? key, required this.chatDocumentId,required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final textController = TextEditingController();

    void sendMessage() async {
      final text = textController.text;
      if (text.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatDocumentId)
            .collection('messages')
            .add({
          'text': text,
          'createdAt': Timestamp.now(),
          'userId': user!.uid,
        });
        textController.clear();
      }
    }

    String _formatTime(DateTime dateTime) {
      String hour = dateTime.hour.toString().padLeft(2, '0');
      String minute = dateTime.minute.toString().padLeft(2, '0');
      String period = dateTime.hour < 12 ? 'AM' : 'PM';
      hour = (dateTime.hour % 12).toString().padLeft(2, '0');
      return '$hour:$minute $period';
    }

    String _formatDate(DateTime dateTime) {
      String day = dateTime.day.toString().padLeft(2, '0');
      String month = dateTime.month.toString().padLeft(2, '0');
      String year = dateTime.year.toString();
      return '$day $month $year';
    }

    String formatTimestamp(Timestamp timestamp) {
      DateTime dateTime = timestamp.toDate();
      DateTime now = DateTime.now();

      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        // Today's message
        return _formatTime(dateTime);
      } else {
        // Message from a different day
        return '${_formatTime(dateTime)}, ${_formatDate(dateTime)}';
      }
    }

    return Column(
      children: [
        Center(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Dr.$name',style: GoogleFonts.poppins(letterSpacing: 1,fontWeight: FontWeight.w600),),
        ),),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(chatDocumentId)
                .collection('messages')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final messages = snapshot.data!.docs;
              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isCurrentUser = message['userId'] == user?.uid;
                  final messageTime = formatTimestamp(message['createdAt']);
                  return Align(
                    alignment: isCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.cyan
                                  : Colors.cyan.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isCurrentUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['text'],
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  messageTime,
                                  style: const TextStyle(
                                      color: Colors.black38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your message...',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyan),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.cyan),
                    onPressed: sendMessage,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
