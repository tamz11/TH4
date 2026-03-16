import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:th4/models/product.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com/products?limit=100';
  static const String _categoriesUrl = 'https://dummyjson.com/products/categories';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode != 200) {
      throw Exception('Không thể tải sản phẩm');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final products = (data['products'] as List<dynamic>? ?? []);

    return products
        .map((item) {
          final raw = item as Map<String, dynamic>;
          final normalized = <String, dynamic>{
            'id': raw['id'],
            'title': raw['title'],
            'description': raw['description'],
            'price': raw['price'],
            'image': raw['thumbnail'] ?? '',
            'category': raw['category'] ?? '',
            'rating': {
              'rate': raw['rating'] ?? 4.5,
              'count': raw['stock'] ?? 100,
            },
          };
          return Product.fromJson(normalized);
        })
        .toList();
  }

  Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse(_categoriesUrl));
    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh mục');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      return [];
    }

    return data
        .map((item) {
          if (item is String) {
            return item;
          }
          if (item is Map<String, dynamic>) {
            return (item['slug'] ?? item['name'] ?? '').toString();
          }
          return '';
        })
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }
}
