import 'package:th4/models/product.dart';

class CartItem {
  final Product product;
  final String size;
  final String color;
  final int quantity;
  final bool selected;

  const CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
    this.selected = true,
  });

  String get key => '${product.id}-$size-$color';

  double get lineTotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    String? size,
    String? color,
    int? quantity,
    bool? selected,
  }) {
    return CartItem(
      product: product ?? this.product,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
    );
  }

  factory CartItem.fromStorageJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromStorageJson(json['product'] as Map<String, dynamic>),
      size: (json['size'] ?? 'M') as String,
      color: (json['color'] ?? 'Do') as String,
      quantity: (json['quantity'] as int?) ?? 1,
      selected: (json['selected'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'product': product.toStorageJson(),
      'size': size,
      'color': color,
      'quantity': quantity,
      'selected': selected,
    };
  }
}
