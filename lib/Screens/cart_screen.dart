import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase.instance.ref();
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: StreamBuilder(
        stream: database.child('cart').child(currentUser.uid).onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Your cart is empty'));
          }
          final cartItems = Map<dynamic, dynamic>.from(
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
          final cartList = cartItems.entries
              .map((entry) => {
                    'id': entry.key,
                    ...Map<String, dynamic>.from(entry.value),
                  })
              .toList();

          return ListView.builder(
            itemCount: cartList.length,
            itemBuilder: (context, index) {
              final cartItem = cartList[index];
              return FutureBuilder(
                future: database
                    .child('products')
                    .child(cartItem['id'])
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
                    subtitle: Text('₹${product['price']} x ${cartItem['quantity']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        database
                            .child('cart')
                            .child(currentUser.uid)
                            .child(cartItem['id'])
                            .remove();
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              final snapshot = await database.child('cart').child(currentUser.uid).get();
              if (snapshot.value != null) {
                final cartItems = Map<dynamic, dynamic>.from(snapshot.value as Map);
                for (var entry in cartItems.entries) {
                  await database.child('orders').child(currentUser.uid).push().set({
                    'productId': entry.key,
                    'quantity': entry.value['quantity'],
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                  });
                }
                await database.child('cart').child(currentUser.uid).remove();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order placed successfully')),
                );
              }
            },
            child: const Text('Place Order'),
          ),
        ),
      ),
    );
  }
}