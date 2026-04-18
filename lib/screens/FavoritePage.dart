import 'package:flutter/material.dart';
import '../models/prduct_model.dart';
import '../services/favorite_service.dart';
// import 'add_product_page.dart';
import 'productCardlogic.dart'; 

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final service = FavoriteService();
  List<Animal> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadFavorites();
  }
  Future<void> loadFavorites() async {
    final data = await service.getFavorites();
    setState(() {
      favorites = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Избранные ❤️"),
      ),
      body: RefreshIndicator(
        onRefresh: loadFavorites, 
        child: favorites.isEmpty
            ? ListView( // 
                children: const [
                  SizedBox(height: 300),
                  Center(child:Text("Нет избранных товаров")),
                  // Center(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       //  нажатми и узнаешь
                  //       Navigator.pushRe(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) =>  AddProductPage(),
                  //         ),
                  //       );
                  //     },
                  //     child: const Text("Добавить товар"),
                  //   ),
                  // ),
                ],
              )
            : GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: favorites.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: favorites[index],
                  );
                },
              ),
      ),
    );
  }
}