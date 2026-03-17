import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:th4/providers/cart_provider.dart';
import 'package:th4/screens/checkout_screen.dart';
import 'package:th4/screens/orders_screen.dart';
import 'package:th4/utils/currency.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Giỏ hàng'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined),
              ),
            ],
          ),
          body: cart.items.isEmpty
              ? const Center(child: Text('Giỏ hàng trống'))
              : ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Dismissible(
                      key: Key(item.key),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => cart.removeItem(item.key),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: item.selected,
                              onChanged: (v) =>
                                  cart.toggleItem(item.key, v ?? false),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.image,
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Size ${item.size} - ${item.color}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatVnd(item.product.price),
                                    style: const TextStyle(
                                      color: Color(0xFFEE4D2D),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      cart.increaseQuantity(item.key),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  onPressed: () async {
                                    if (item.quantity == 1) {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Xóa sản phẩm?'),
                                          content: const Text(
                                            'Bạn có muốn xóa sản phẩm này?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Không'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Xóa'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true) {
                                        cart.removeItem(item.key);
                                      }
                                    } else {
                                      cart.decreaseQuantity(item.key);
                                    }
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          bottomNavigationBar: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
            child: Row(
              children: [
                Checkbox(
                  value: cart.isAllSelected,
                  onChanged: (v) => cart.toggleSelectAll(v ?? false),
                ),
                const Text('Chọn tất cả'),
                const Spacer(),
                Text(
                  'Tổng: ${formatVnd(cart.selectedTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: cart.selectedItems.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CheckoutScreen(items: cart.selectedItems),
                            ),
                          );
                        },
                  child: const Text('Thanh toán'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
