import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _database = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  String _getChatId() {
    final userId = _auth.currentUser!.uid;
    return userId.compareTo(widget.receiverId) < 0
        ? '${userId}_${widget.receiverId}'
        : '${widget.receiverId}_${userId}';
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final chatId = _getChatId();
    final message = {
      'senderId': _auth.currentUser!.uid,
      'receiverId': widget.receiverId,
      'text': _messageController.text.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _database.child('chats').child(chatId).push().set(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatId = _getChatId();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: const Color(0xFF2874F0),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _database.child('chats').child(chatId).orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No messages yet'));
                }
                final messages = Map<dynamic, dynamic>.from(
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
                final messageList = messages.entries
                    .map((entry) => {
                          'id': entry.key,
                          ...Map<String, dynamic>.from(entry.value),
                        })
                    .toList()
                  ..sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

                return ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    final message = messageList[index];
                    final isMe = message['senderId'] == _auth.currentUser!.uid;
                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF2874F0) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                      subtitle: Text(
                        DateTime.fromMillisecondsSinceEpoch(message['timestamp'])
                            .toString(),
                        textAlign: isMe ? TextAlign.right : TextAlign.left,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2874F0)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}