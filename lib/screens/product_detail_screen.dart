import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:th4/models/cart_item.dart';
import 'package:th4/models/product.dart';
import 'package:th4/providers/cart_provider.dart';
import 'package:th4/screens/cart_screen.dart';
import 'package:th4/screens/checkout_screen.dart';
import 'package:th4/utils/currency.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _showMore = false;

  Future<void> _openSelectSheet({required bool buyNow}) async {
    String selectedSize = 'M';
    String selectedColor = 'Đỏ';
    int qty = 1;

    final result = await showModalBottomSheet<CartItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chọn phân loại',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Size'),
                    Wrap(
                      spacing: 8,
                      children: ['S', 'M', 'L']
                          .map(
                            (size) => ChoiceChip(
                              label: Text(size),
                              selected: selectedSize == size,
                              onSelected: (_) => setModalState(() => selectedSize = size),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Màu sắc'),
                    Wrap(
                      spacing: 8,
                      children: ['Đỏ', 'Xanh']
                          .map(
                            (color) => ChoiceChip(
                              label: Text(color),
                              selected: selectedColor == color,
                              onSelected: (_) =>
                                  setModalState(() => selectedColor = color),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Số lượng'),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (qty > 1) {
                              setModalState(() => qty--);
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$qty', style: const TextStyle(fontSize: 16)),
                        IconButton(
                          onPressed: () => setModalState(() => qty++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            CartItem(
                              product: widget.product,
                              size: selectedSize,
                              color: selectedColor,
                              quantity: qty,
                              selected: true,
                            ),
                          );
                        },
                        child: Text(buyNow ? 'Mua ngay' : 'Xác nhận'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    context.read<CartProvider>().addItem(
          product: result.product,
          size: result.size,
          color: result.color,
          quantity: result.quantity,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thêm thành công')),
    );

    if (buyNow) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CheckoutScreen(items: [result])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalPrice = widget.product.price * 1.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 320,
            child: PageView(
              children: widget.product.images
                  .map(
                    (img) => Hero(
                      tag: 'product-${widget.product.id}',
                      child: Image.network(img, fit: BoxFit.contain),
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      formatVnd(widget.product.price),
                      style: const TextStyle(
                        color: Color(0xFFEE4D2D),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatVnd(originalPrice),
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: Colors.white,
            title: const Text('Phân loại'),
            subtitle: const Text('Chọn Kích cỡ, Màu sắc'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openSelectSheet(buyNow: false),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  widget.product.description,
                  maxLines: _showMore ? null : 5,
                  overflow: _showMore ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                TextButton(
                  onPressed: () => setState(() => _showMore = !_showMore),
                  child: Text(_showMore ? 'Thu gọn' : 'Xem thêm'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _openSelectSheet(buyNow: false),
                child: const Text('Thêm vào giỏ'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => _openSelectSheet(buyNow: true),
                child: const Text('Mua ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
