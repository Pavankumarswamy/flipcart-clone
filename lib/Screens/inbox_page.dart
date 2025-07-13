import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chat_screen.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase.instance.ref();
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF2874F0),
      ),
      body: StreamBuilder(
        stream: database.child('chats').onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('No conversations found'));
          }

          final chats = Map<dynamic, dynamic>.from(
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
          final conversationUsers = <String, Map<String, dynamic>>{};
          for (var chatEntry in chats.entries) {
            final chatId = chatEntry.key;
            final messages = Map<dynamic, dynamic>.from(chatEntry.value);
            final latestMessage = messages.entries
                .map((e) => {
                      'id': e.key,
                      ...Map<String, dynamic>.from(e.value),
                    })
                .toList()
              ..sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));

            if (latestMessage.isNotEmpty) {
              final message = latestMessage.first;
              final otherUserId = message['senderId'] == currentUser.uid
                  ? message['receiverId']
                  : message['senderId'];
              if (!conversationUsers.containsKey(otherUserId)) {
                conversationUsers[otherUserId] = {
                  'chatId': chatId,
                  'latestMessage': message['text'],
                  'timestamp': message['timestamp'],
                };
              }
            }
          }

          if (conversationUsers.isEmpty) {
            return const Center(child: Text('No conversations found'));
          }

          return ListView.builder(
            itemCount: conversationUsers.length,
            itemBuilder: (context, index) {
              final otherUserId = conversationUsers.keys.elementAt(index);
              final conversation = conversationUsers[otherUserId]!;
              return FutureBuilder(
                future: database
                    .child('users')
                    .child(otherUserId)
                    .get()
                    .then((snapshot) => snapshot.value as Map<dynamic, dynamic>?),
                builder: (context, AsyncSnapshot<Map<dynamic, dynamic>?> userSnapshot) {
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return const ListTile(title: Text('Loading...'));
                  }
                  final user = userSnapshot.data!;
                  final userName = user['name'] ?? 'Seller';
                  final profileUrl = user['profileUrl'] ?? '';
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: otherUserId,
                            receiverName: userName,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(profileUrl),
                        radius: 25,
                      ),
                      title: Text(userName),
                      subtitle: Text(
                        conversation['latestMessage'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatTimestamp(conversation['timestamp']),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }
}