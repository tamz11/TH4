import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:th4/models/cart_item.dart';
import 'package:th4/providers/cart_provider.dart';
import 'package:th4/providers/order_provider.dart';
import 'package:th4/utils/currency.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;

  const CheckoutScreen({super.key, required this.items});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController =
  TextEditingController(text: '123 Lê Lợi, TP.HCM');
  String _payment = 'COD';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.fold<double>(0, (sum, item) => sum + item.lineTotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Địa chỉ nhận hàng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 14),
            const Text('Phương thức thanh toán',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(value: 'COD', label: Text('COD')),
              ButtonSegment<String>(value: 'Momo', label: Text('MoMo')),
            ],
            selected: {_payment},
            onSelectionChanged: (selection) {
              setState(() => _payment = selection.first);
            },
          ),
          const SizedBox(height: 12),
            const Text('Sản phẩm đã chọn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...widget.items.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              title: Text(item.product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('x${item.quantity} - ${item.size}/${item.color}'),
              trailing: Text(formatVnd(item.lineTotal)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Tổng: ${formatVnd(total)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(context);

                context.read<OrderProvider>().placeOrder(
                      items: widget.items,
                      address: _addressController.text,
                      paymentMethod: _payment,
                    );

                final cart = context.read<CartProvider>();
                for (final item in widget.items) {
                  cart.removeItem(item.key);
                }

                await showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Đặt hàng thành công'),
                    content: const Text('Đơn hàng đã được tạo.'),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );

                if (!mounted) {
                  return;
                }
                navigator.popUntil((route) => route.isFirst);
              },
              child: const Text('Đặt hàng'),
            ),
          ],
        ),
      ),
    );
  }
}
