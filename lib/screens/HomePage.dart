import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:socpet/login.dart';
// import 'package:socpet/screens/aiPage.dart';
import '../models/prduct_model.dart';
import 'productCardlogic.dart';
// import 'package:socpet/screens/main_page.dart';
import 'ItemInfo.dart';
import 'create_order_new.dart';
import 'info_order.dart';

// import 'Walking_page.dart';
// import '../models/mainpage_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/work_service.dart';
// import '../services/oreder_service.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text('Not logged in'));

    final animalsRef = FirebaseFirestore.instance
    .collection('products')
    .orderBy('createdAt', descending: true);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(children: [
        const SizedBox(height: 10),

SizedBox(
  height: 100,
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: [


      _buildCategory(
        icon: Icons.directions_walk,
        title: "Создание заказа",
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateOrderPage(serviceType: "walking"),
            ),
          );
        },
      ),

      _buildCategory(
        icon: Icons.home,
        title: "Выбор услуг",
        color: Colors.pink.shade300,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServicesPage()),
          );
        },
      ),

      _buildCategory(
        icon: Icons.shopping_bag,
        title: "Мои заказы",
        color: Colors.green,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrdersPage()),
          );
        },
      ),
      
    ],
  ),
),
        SearchAndFilter(
          onChanged: (value) => setState(() => query = value),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: animalsRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final docs = snapshot.data!.docs
                  .where((doc) => doc['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
                                  doc['description'].toString().toLowerCase().contains(query.toLowerCase()))
                  .toList();

              if (docs.isEmpty) return const Center(child: Text('No animals found'));

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.65,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index];
                  final product = Animal(
                    id: data.id,
                    name: data['name'],
                    price: data['price']  ,
                    decount: 0,
                    age: 0,
                    description: data['description'],
                    images: data['image'],
                    Status: data['status'] ?? "For Sale",
                  );
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ItemInfo(product: product)),
                      );
                    },
                    child: ProductCard(product: product),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

class SearchAndFilter extends StatelessWidget { final Function(String) onChanged; const SearchAndFilter({super.key, required this.onChanged}); @override Widget build(BuildContext context) { return Padding( padding: const EdgeInsets.all(16), child: TextField( onChanged: onChanged, decoration: InputDecoration( hintText: 'Поиск товаров...', prefixIcon: Icon(Icons.search), ), ), ); } } class ResultsList extends StatelessWidget { final String query; final List<Animal> products; const ResultsList({ super.key, required this.query, required this.products, }); @override Widget build(BuildContext context) { final filtered = products.where((product) { return product.description .toLowerCase() .contains(query.toLowerCase()); }).toList(); if (filtered.isEmpty) { return const Text(""); } return GridView.builder( padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.65, ), itemCount: filtered.length, itemBuilder: (context, index) { final product = filtered[index]; return GestureDetector( onTap: () { Navigator.push( context, MaterialPageRoute( builder: (context) => ItemInfo(product: product), ), ); }, child: ProductCard(product: product), ); }, ); } }

// class ProductCard extends StatelessWidget {
//   final Animal product;

//   const ProductCard({super.key, required this.product});

//   @override
//   Widget build(BuildContext context) {

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white,
//         border: Border.all(color: Colors.grey.shade300, width: 1), 
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius:  BorderRadius.circular(12),
//                 child: Image.asset(
//                   product.images,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: 170,
//                 ),
//               ),

//               Positioned(
//                 bottom: 10,
//                 left: 10,
//                 height: 30,
//                 child: Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFF0600),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(product.Status,
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 0,
//                 right: 10,
//                 child: Container(
//                   padding: const EdgeInsets.only(right: 4,left: 4,top: 1,bottom:1),
//                   // decoration: BoxDecoration(
//                   //   color: Colors.black.withOpacity(0.35),
//                   //   borderRadius: BorderRadius.circular(11),
//                   // ),
//                   child: 
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       IconButton(icon: Icon(Icons.favorite_border_outlined ,color: Colors.white ,size: 25,),
//                         onPressed: () {
//                           print("Add to Favorite");
//                         },
//                       ),
//                       // Text(,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold ),),
//                     ] 
//                   )
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 5),
//                       Text(product.name),
//                       Row(
//                         children: [
//                           Text(product.price.toString(),
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.redAccent,
//                               )),
//                           SizedBox(width: 10),
//                           Text(product.decount.toString(),
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 decoration: TextDecoration.lineThrough,
//                               )),
//                         ],
//                       ),
//                       SizedBox(height: 6),

//                       Expanded(
//                         child: Text(
//                           product.description,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Icon(Icons.more_vert),
//                 PopupMenuButton<String>(
//                   color: Colors.white,
//                   onSelected: (value) {
//                     print("You choise: $value");
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
//                     const PopupMenuItem(value: 'delete', child: Text('Удалить')),
//                     const PopupMenuItem(value: 'share', child: Text('Поделиться')),
//                     const PopupMenuItem(value: 'Add in Favorite', child: Text('Добавить в избранные')),
//                     const PopupMenuItem(value: 'Hide', child: Text('Скрыть')),
//                   ],
//                   child: const Icon(Icons.more_vert), 
//                 )
//               ],
//             ),
//           ),
//           )
//         ]
//       ),
//     );
//   }
// }


Widget _buildCategory({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),

      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(icon, size: 30, color: color),

          const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    ),
  );
}