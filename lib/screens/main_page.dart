import 'package:flutter/material.dart';
import '../login.dart';
import 'keeping_page.dart';
import 'FavoritePage.dart';
import 'add_product_page.dart';
import 'ProfilePage.dart';
import 'HomePage.dart';
import 'shop_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'aiPage.dart';
import '../profile_page.dart';
import '../models/user_model.dart'; 
import '../services/user_services.dart'; 



class MainPage extends StatefulWidget{
  const MainPage ({super.key});

   @override
  State<MainPage> createState() => _main_page();
}

class _main_page extends State<MainPage> {

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const FavoritePage(),
    const AddAnimalPage(),
    const ShopPage(),
    const AIChatScreen(),
  ];
  AppUser? _user; 
  final UserService _userService = UserService(); 

  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    loadUserName();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _user = await _userService.getUserData(uid); 
      setState(() {}); // обновим вид
    }
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "User";
      userEmail = prefs.getString('userEmail') ?? "";
    });
  }
  String _getTitle() {
  switch (_currentIndex) {
    case 0: return "Home";
    case 1: return "Favorite";
    case 2: return "Add";
    case 3: return "Shop";
    default: return "ai";
  }
}



  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _currentIndex == 0
    ? AppBar(
        title: Text(_getTitle()),
      )
    : null,
      endDrawer: _currentIndex == 4 
    ? null 
    : Drawer(
        child:  ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFF3AB3F),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _user?.photoURL != null
                        ? NetworkImage(_user!.photoURL!) as ImageProvider
                        : AssetImage("assets/image/pet1.jpg"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _user?.name ?? "User", 
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    _user?.email ?? userEmail,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap:  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.logout),
            //   title: const Text("Logout"),
            //   onTap: () async {

            //     await FirebaseAuth.instance.signOut();

            //     // Очистка локальных данных ведь нельзя оставлять историй бра№№№
            //     final prefs = await SharedPreferences.getInstance();
            //     await prefs.clear();

            //     if (context.mounted) {
            //       Navigator.pushAndRemoveUntil(
            //         context,
            //         MaterialPageRoute(builder: (_) => const Login_Page()),
            //         (route) => false,
            //       );
            //     }
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favorites"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>     const FavoritePage()),
                  // (route) => false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfile()),
                  // (route) => false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.no_accounts),
              title: const Text("Support"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyApp()),
                  // (route) => false,
                );
              },
            ),

          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Colors.blue,
        
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Color(0xFFF3AB3F),
            icon: Icon(Icons.home_filled,),
            label: "Home",
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFFF3AB3F),
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFFF3AB3F),
            icon: Icon(Icons.pets_outlined),
            label: "Add card",
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFFF3AB3F),
            icon: Icon(Icons.store_mall_directory_outlined),
            label: "Store",
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFFF3AB3F),
            icon: Icon(Icons.bolt),
            label: "AI",
          ),
        ],
      ),
    );
  }
}