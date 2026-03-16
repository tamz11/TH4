import 'package:flutter/foundation.dart';
import 'package:th4/models/cart_item.dart';
import 'package:th4/models/order.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);

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
      status: 'Cho xac nhan',
    );

    _orders.insert(0, order);
    notifyListeners();
  }
}
