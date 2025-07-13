import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _categoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for products, brands and more',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() {}),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  'All',
                  'Electronics',
                  'Clothing',
                  'Books',
                  'Home & Furniture'
                ].map((category) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _categoryFilter == category,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _categoryFilter = category;
                            });
                          }
                        },
                        selectedColor: const Color(0xFF2874F0),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _categoryFilter == category ? Colors.white : Colors.black,
                        ),
                      ),
                    )).toList(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: database.child('products').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No products found'));
                }
                final products = Map<dynamic, dynamic>.from(
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
                final productList = products.entries
                    .map((entry) => {
                          'id': entry.key,
                          ...Map<String, dynamic>.from(entry.value),
                        })
                    .where((product) =>
                        _searchController.text.isEmpty ||
                        product['name']
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                    .where((product) =>
                        _categoryFilter == 'All' ||
                        product['category'] == _categoryFilter)
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    return Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: product['imageUrl'],
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('₹${product['price']}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await database
                                          .child('cart')
                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                          .child(product['id'])
                                          .set({
                                        'quantity': 1,
                                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Added to cart')),
                                      );
                                    },
                                    child: const Text('Add to Cart'),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message, color: Color(0xFF2874F0)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          receiverId: product['sellerId'] ?? 'admin',
                                          receiverName: 'Seller',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}