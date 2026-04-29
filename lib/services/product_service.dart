import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class ProductService {
  static const _apiUrl = 'https://dummyjson.com/products?limit=30';
  static const _cacheKey = 'cached_products';

  Future<List<Product>> fetchFromApi() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar produtos');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawProducts = data['products'] as List<dynamic>;
    final products = rawProducts
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();

    await _saveToCache(products);

    return products;
  }

  Future<List<Product>> fetchFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached == null) return [];

    final List<dynamic> rawList = jsonDecode(cached) as List<dynamic>;
    return rawList
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveToCache(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(products.map((p) => p.toMap()).toList());
    await prefs.setString(_cacheKey, encoded);
  }
}
