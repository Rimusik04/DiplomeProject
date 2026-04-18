import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Модель товара из локалки так как это идея сложная 
class ShopItem {
  final String id;
  final String name;
  final String category;
  final String image;
  final double price;
  final String description;
  final bool inStock;

  ShopItem({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.price,
    required this.description,
    required this.inStock,
  });
}

// локал продукт
final List<ShopItem> shopItems = [
  ShopItem(
    id: "1",
    name: "Сухой корм",
    category: "Еда",
    image: "assets/image/food1.jpg",
    price: 5000,
    description: "Премиальный сухой корм для собак всех пород. Содержит все необходимые витамины и минералы.",
    inStock: true,
  ),
  ShopItem(
    id: "2",
    name: "Поводок нейлоновый",
    category: "Аксессуары",
    image: "assets/image/leash.jpg",
    price: 2000,
    description: "Прочный нейлоновый поводок длиной 2 метра. Регулируемая длина, удобная ручка.",
    inStock: true,
  ),
  ShopItem(
    id: "3",
    name: "Влажный корм",
    category: "Еда",
    image: "assets/image/wet_food.jpg",
    price: 3500,
    description: "Влажный корм в паучах для кошек и собак. Гипоаллергенный состав.",
    inStock: false,
  ),
  ShopItem(
    id: "4",
    name: "Ошейник светящийся",
    category: "Аксессуары",
    image: "assets/image/collar.jpg",
    price: 4500,
    description: "Светящийся ошейник для ночных прогулок. Регулируемый размер, водонепроницаемый.",
    inStock: true,
  ),
  ShopItem(
    id: "5",
    name: "Игрушка-пищалка",
    category: "Игрушки",
    image: "assets/image/toy.jpg",
    price: 1500,
    description: "Мягкая игрушка с пищалкой. Безопасные материалы, подходит для активных игр.",
    inStock: true,
  ),
];

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String selectedCategory = "Все";
  List<String> categories = ["Все", "Еда", "Аксессуары", "Игрушки"];
  
  final Color primaryColor = const Color(0xFFF3AB3F);
  Map<String, int> cartItems = {};
  Set<String> favoriteItems = {};

  @override
  void initState() {
    super.initState();
    loadCartItems();
    loadFavoriteItems();
    print('✅ Загружено товаров: ${shopItems.length}'); // это для меня 
    for (var item in shopItems) {
      print('   - ${item.name} (${item.category})');
    }
  }
  Future<void> loadCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      DocumentSnapshot cartDoc = await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .get();
      
      if (cartDoc.exists) {
        setState(() {
          cartItems = Map<String, int>.from(cartDoc['items'] ?? {});
        });
      }
    } catch (e) {
      print('Ошибка загрузки корзины: $e');
    }
  }
  
  // Сохранение корзины в облока для начало так а потом уже сделаем и заказы напрямую с магазина или тг бота
  Future<void> saveCartToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .set({
        'items': cartItems,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Ошибка сохранения корзины: $e');
    }
  }
  Future<void> loadFavoriteItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      DocumentSnapshot favDoc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(user.uid)
          .get();
      
      if (favDoc.exists) {
        setState(() {
          favoriteItems = Set<String>.from(favDoc['items'] ?? []);
        });
      }
    } catch (e) {
      print('Ошибка загрузки избранного: $e');
    }
  }
  
  Future<void> saveFavoriteToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(user.uid)
          .set({
        'items': favoriteItems.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Ошибка сохранения избранного: $e');
    }
  }
  
  void addToCart(ShopItem item) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginDialog();
      return;
    }
    
    setState(() {
      if (cartItems.containsKey(item.id)) {
        cartItems[item.id] = cartItems[item.id]! + 1;
      } else {
        cartItems[item.id] = 1;
      }
    });
    
    saveCartToFirebase();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} добавлен в корзину'),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Перейти',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }
  
  void toggleFavorite(ShopItem item) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginDialog();
      return;
    }
    
    setState(() {
      if (favoriteItems.contains(item.id)) {
        favoriteItems.remove(item.id);
        _showToast('Удалено из избранного');
      } else {
        favoriteItems.add(item.id);
        _showToast('Добавлено в избранное');
      }
    });
    
    saveFavoriteToFirebase();
  }
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Требуется авторизация'),
        content: const Text('Войдите в аккаунт, чтобы добавлять товары'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }
  void _showItemDetails(ShopItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            item.image,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 50),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                favoriteItems.contains(item.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: favoriteItems.contains(item.id)
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                toggleFavorite(item);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${item.price} ₸',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Описание',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description.isNotEmpty 
                              ? item.description 
                              : 'Нет описания',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Характеристики',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildSpecRow('Категория', item.category),
                              _buildSpecRow(
                                'Наличие',
                                item.inStock ? 'В наличии' : 'Нет в наличии',
                                color: item.inStock ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: item.inStock 
                        ? () {
                            addToCart(item);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      item.inStock ? 'Добавить в корзину' : 'Нет в наличии',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSpecRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = selectedCategory == "Все"
        ? shopItems
        : shopItems
            .where((item) => item.category == selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Магазин',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                      iconSize: 28,
                    ),
                    if (cartItems.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            cartItems.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // количества товаров
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Товары",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${filteredItems.length} шт.",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Товары
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет товаров в категории "$selectedCategory"',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ShopItemCard(
                        item: item,
                        primaryColor: primaryColor,
                        isFavorite: favoriteItems.contains(item.id),
                        onFavoriteToggle: () => toggleFavorite(item),
                        onAddToCart: () => addToCart(item),
                        onTap: () => _showItemDetails(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final Color primaryColor;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.primaryColor,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    item.image,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 130,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
                //  категории
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                // наличия или количкества
                if (!item.inStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Нет в наличии',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorite ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Инфо
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.price} ₸",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: item.inStock ? onAddToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        item.inStock ? "Купить" : "Нет",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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