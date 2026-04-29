import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  static const _apiUrl = 'https://dummyjson.com/products?limit=30';

  Future<List<Product>> fetchFromApi() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar produtos');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawProducts = data['products'] as List<dynamic>;
    return rawProducts
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
