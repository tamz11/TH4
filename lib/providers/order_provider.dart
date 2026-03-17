import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:th4/models/cart_item.dart';
import 'package:th4/models/order.dart';

class OrderProvider extends ChangeNotifier {
  static const String _storageKey = 'th4_orders';
  final List<OrderModel> _orders = [];

  OrderProvider() {
    _loadFromStorage();
  }

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);

  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  void placeOrder({
    required List<CartItem> items,
    required String address,
    required String paymentMethod,
  }) {
    final total = items.fold<double>(0, (sum, item) => sum + item.lineTotal);

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List<CartItem>.from(items),
      total: total,
      address: address,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      status: 'pending', // 'pending', 'shipping', 'delivered', 'cancelled'
    );

    _orders.insert(0, order);
    _saveToStorage();
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;

      final data = jsonDecode(raw) as List<dynamic>;
      _orders.clear();
      for (final item in data) {
        _orders.add(OrderModel.fromStorageJson(item as Map<String, dynamic>));
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _orders.map((o) => o.toStorageJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(data));
  }
}
