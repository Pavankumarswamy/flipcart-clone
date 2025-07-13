import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase.instance.ref();
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: const Color(0xFF2874F0),
        actions: [
          if (userId == currentUser.uid)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            FutureBuilder(
              future: database.child('users').child(userId).get(),
              builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data!.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final user = Map<String, dynamic>.from(snapshot.data!.value as Map<dynamic, dynamic>);
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(user['profileUrl'] ?? ''),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? 'Unknown',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(user['email'] ?? ''),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            // Orders Section
            if (userId == currentUser.uid)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Orders',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    StreamBuilder(
                      stream: database.child('orders').child(userId).onValue,
                      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No orders found'),
                          );
                        }
                        final orders = Map<dynamic, dynamic>.from(
                            snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
                        final orderList = orders.entries
                            .map((entry) => {
                                  'id': entry.key,
                                  ...Map<String, dynamic>.from(entry.value),
                                })
                            .toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderList.length,
                          itemBuilder: (context, index) {
                            final order = orderList[index];
                            return FutureBuilder(
                              future: database
                                  .child('products')
                                  .child(order['productId'])
                                  .get()
                                  .then((snapshot) => snapshot.value as Map<dynamic, dynamic>?),
                              builder: (context, AsyncSnapshot<Map<dynamic, dynamic>?> productSnapshot) {
                                if (!productSnapshot.hasData || productSnapshot.data == null) {
                                  return const ListTile(title: Text('Loading...'));
                                }
                                final product = productSnapshot.data!;
                                return ListTile(
                                  leading: Image.network(
                                    product['imageUrl'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                  ),
                                  title: Text(product['name']),
                                  subtitle: Text('Quantity: ${order['quantity']}'),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}