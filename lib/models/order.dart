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

  factory OrderModel.fromStorageJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromStorageJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      address: json['address'] as String,
      paymentMethod: json['paymentMethod'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toStorageJson()).toList(),
      'total': total,
      'address': address,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
