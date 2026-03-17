import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:th4/models/cart_item.dart';
import 'package:th4/models/product.dart';

class CartProvider extends ChangeNotifier {
  static const String _cartStorageKey = 'th4_cart_items';
  final Map<String, CartItem> _items = {};

  CartProvider() {
    _loadFromStorage();
  }

  List<CartItem> get items => _items.values.toList();
  int get badgeCount => _items.length;

  bool get isAllSelected =>
      items.isNotEmpty && items.every((item) => item.selected);

  List<CartItem> get selectedItems =>
      items.where((item) => item.selected).toList(growable: false);

  double get selectedTotal {
    return items
        .where((item) => item.selected)
        .fold(0, (sum, item) => sum + item.lineTotal);
  }

  void addItem({
    required Product product,
    required String size,
    required String color,
    required int quantity,
  }) {
    final key = '${product.id}-$size-$color';
    final existing = _items[key];

    if (existing != null) {
      _items[key] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      _items[key] = CartItem(
        product: product,
        size: size,
        color: color,
        quantity: quantity,
        selected: true,
      );
    }

    _saveToStorage();
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    _saveToStorage();
    notifyListeners();
  }

  void toggleItem(String key, bool value) {
    final item = _items[key];
    if (item == null) {
      return;
    }
    _items[key] = item.copyWith(selected: value);
    _saveToStorage();
    notifyListeners();
  }

  void toggleSelectAll(bool value) {
    for (final entry in _items.entries) {
      _items[entry.key] = entry.value.copyWith(selected: value);
    }
    _saveToStorage();
    notifyListeners();
  }

  void increaseQuantity(String key) {
    final item = _items[key];
    if (item == null) {
      return;
    }
    _items[key] = item.copyWith(quantity: item.quantity + 1);
    _saveToStorage();
    notifyListeners();
  }

  void decreaseQuantity(String key) {
    final item = _items[key];
    if (item == null) {
      return;
    }

    if (item.quantity <= 1) {
      _items.remove(key);
    } else {
      _items[key] = item.copyWith(quantity: item.quantity - 1);
    }
    _saveToStorage();
    notifyListeners();
  }

  void removeSelectedItems() {
    _items.removeWhere((_, item) => item.selected);
    _saveToStorage();
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cartStorageKey);
      if (raw == null || raw.isEmpty) {
        return;
      }

      final data = jsonDecode(raw) as List<dynamic>;
      _items.clear();

      for (final item in data) {
        final cartItem = CartItem.fromStorageJson(item as Map<String, dynamic>);
        _items[cartItem.key] = cartItem;
      }

      notifyListeners();
    } catch (_) {
      // Ignore invalid cache and keep app usable.
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.values.map((item) => item.toStorageJson()).toList();
    await prefs.setString(_cartStorageKey, jsonEncode(data));
  }
}
