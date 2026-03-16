import 'package:th4/models/cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final String address;
  final String paymentMethod;
  final DateTime createdAt;
  final String status;

  const OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
    required this.status,
  });
}
