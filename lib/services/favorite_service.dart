import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prduct_model.dart';

class FavoriteService {
  static const String key = 'favorites';

  Future<List<Animal>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(key) ?? [];
    return jsonList.map((item) {
      final data = jsonDecode(item);
      return Animal(
        id: data['id'],
        images: data['images'],
        name: data['name'],
        price: data['price'],
        decount: data['decount'],
        description: data['description'],
        age: data['age'],
        Status: data['Status'],
      );
    }).toList();
  }

  Future<bool> isFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(key) ?? [];
    return jsonList.any((item) {
      final data = jsonDecode(item);
      return data['id'] == id;
    });
  }

  Future<void> toggleFavorite(Animal animal) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(key) ?? [];

    final existsIndex = jsonList.indexWhere((item) {
      final data = jsonDecode(item);
      return data['id'] == animal.id;
    });

    if (existsIndex >= 0) {
      jsonList.removeAt(existsIndex);
    } else {
      jsonList.add(jsonEncode({
        'id': animal.id,
        'images': animal.images,
        'name': animal.name,
        'price': animal.price,
        'decount': animal.decount,
        'description': animal.description,
        'age': animal.age,
        'Status': animal.Status,
      }));
    }

    await prefs.setStringList(key, jsonList);
  }
}
