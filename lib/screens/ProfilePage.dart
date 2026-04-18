import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/prduct_model.dart';
import 'add_product_page.dart';
import 'ItemInfo.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

    final userRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    final animalsRef = FirebaseFirestore.instance
        .collection("products")
        .where("userId", isEqualTo: user.uid);

    return Scaffold(

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAnimalPage(),
            ),
          );
        },
      ),

      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            // данные чела
            StreamBuilder<DocumentSnapshot>(
              stream: userRef.snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!;

                final name = data["name"] ?? "No name";
                final photo = data["photoURL"];

                return Column(
                  children: [

                    CircleAvatar(
                      radius: 50,
                      backgroundImage: photo != null
                          ? NetworkImage(photo)
                          : const AssetImage("assets/image/dog.jpg")
                              as ImageProvider,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Animals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: animalsRef.snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Text("You don't have animals yet"),
                  );
                }

                return GridView.builder(

                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,

                  ),

                  itemCount: docs.length,

                  itemBuilder: (context, index) {

                    final data = docs[index];

                    final product = Animal(
                      id: data.id,
                      name: data["name"],
                      price: data["price"],
                      decount: 0,
                      age: 0,
                      description: data["description"],
                      images: data["image"],
                      Status: "Available",
                    );

                    return GestureDetector(

                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemInfo(product: product),
                          ),
                        );

                      },

                      child: Card(

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            ClipRRect(

                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),

                              child: Image.network(
                                product.images,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(8),

                              child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "${product.price} ₸",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
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
          ],
        ),
      ),
    );
  }
}