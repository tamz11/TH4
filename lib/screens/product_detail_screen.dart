import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:th4/models/cart_item.dart';
import 'package:th4/models/product.dart';
import 'package:th4/providers/cart_provider.dart';
import 'package:th4/screens/cart_screen.dart';
import 'package:th4/screens/checkout_screen.dart';
import 'package:th4/utils/currency.dart';

// ─── Dữ liệu size & màu tĩnh ─────────────────────────────────────────────────
const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
const _colorOptions = [
  _ColorOption('Đỏ', Color(0xFFE53935)),
  _ColorOption('Xanh dương', Color(0xFF1E88E5)),
  _ColorOption('Xanh lá', Color(0xFF43A047)),
  _ColorOption('Đen', Color(0xFF212121)),
  _ColorOption('Trắng', Color(0xFFF5F5F5)),
  _ColorOption('Vàng', Color(0xFFFDD835)),
];

class _ColorOption {
  final String name;
  final Color color;
  const _ColorOption(this.name, this.color);
}

// ─────────────────────────────────────────────────────────────────────────────

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  // Slider
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Mô tả
  bool _showMore = false;

  // Entrance animations
  late final AnimationController _enterCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    // Delay để Hero transition hoàn tất trước khi chạy animation
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─── Bottom Sheet ──────────────────────────────────────────────────────────

  Future<void> _openSelectSheet({required bool buyNow}) async {
    String selectedSize = 'M';
    int selectedColorIdx = 0;
    int qty = 1;

    final result = await showModalBottomSheet<CartItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final selectedColor = _colorOptions[selectedColorIdx];
            final totalPrice = widget.product.price * qty;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Header: ảnh + tên + giá
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.product.image,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatVnd(totalPrice),
                                    style: const TextStyle(
                                      color: Color(0xFFEE4D2D),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _ChipLabel(
                                    label:
                                        '$selectedSize · ${selectedColor.name}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Màu sắc
                            const _SectionLabel('Màu sắc'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(_colorOptions.length, (
                                i,
                              ) {
                                final opt = _colorOptions[i];
                                final isSelected = selectedColorIdx == i;
                                return GestureDetector(
                                  onTap: () =>
                                      setModalState(() => selectedColorIdx = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? opt.color.withOpacity(0.12)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? opt.color
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: opt.color,
                                            shape: BoxShape.circle,
                                            border:
                                                opt.color ==
                                                    const Color(0xFFF5F5F5)
                                                ? Border.all(
                                                    color: Colors.grey.shade400,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          opt.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? opt.color
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 20),

                            // Size
                            const _SectionLabel('Kích cỡ'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _sizes.map((size) {
                                final isSelected = selectedSize == size;
                                return GestureDetector(
                                  onTap: () =>
                                      setModalState(() => selectedSize = size),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 52,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFEE4D2D)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFEE4D2D)
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 20),

                            // Số lượng
                            Row(
                              children: [
                                const _SectionLabel('Số lượng'),
                                const Spacer(),
                                _QtyButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    if (qty > 1) setModalState(() => qty--);
                                  },
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '$qty',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                _QtyButton(
                                  icon: Icons.add,
                                  onTap: () => setModalState(() => qty++),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Nút xác nhận
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: buyNow
                                      ? const Color(0xFFEE4D2D)
                                      : const Color(0xFFFF7D1A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    CartItem(
                                      product: widget.product,
                                      size: selectedSize,
                                      color: selectedColor.name,
                                      quantity: qty,
                                      selected: true,
                                    ),
                                  );
                                },
                                child: Text(
                                  buyNow ? '⚡  Mua ngay' : '🛒  Thêm vào giỏ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;

    if (buyNow) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(items: [result], isBuyNow: true),
        ),
      );
    } else {
      context.read<CartProvider>().addItem(
        product: result.product,
        size: result.size,
        color: result.color,
        quantity: result.quantity,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Đã thêm vào giỏ hàng'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final originalPrice = product.price * 1.3;
    final discountPct = ((1 - product.price / originalPrice) * 100).round();
    final images = product.images;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. Hero Image Slider
          _buildImageSlider(images, product),

          // 2-5. Phần thông tin (có entrance animation)
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  _buildPriceSection(product, originalPrice, discountPct),
                  const SizedBox(height: 8),
                  _buildStatsSection(product),
                  const SizedBox(height: 8),
                  _buildVariantTile(),
                  const SizedBox(height: 8),
                  _buildDescriptionSection(product),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─── Các sub-widget ────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8)],
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Color(0x20000000), blurRadius: 8),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.shopping_cart_outlined, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildImageSlider(List<String> images, Product product) {
    return Stack(
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final imgWidget = Container(
                color: Colors.white,
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
              );

              // Hero chỉ bọc ảnh đầu tiên để match với ProductCard
              if (index == 0) {
                return Hero(tag: 'product-${product.id}', child: imgWidget);
              }
              return imgWidget;
            },
          ),
        ),

        // Dot indicators
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFEE4D2D)
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),

        // Badge "Mall"
        Positioned(
          top: MediaQuery.of(context).padding.top + 56,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEE4D2D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Mall',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(
    Product product,
    double originalPrice,
    int discountPct,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatVnd(product.price),
                style: const TextStyle(
                  color: Color(0xFFEE4D2D),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  formatVnd(originalPrice),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEE4D2D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFEE4D2D).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  '-$discountPct%',
                  style: const TextStyle(
                    color: Color(0xFFEE4D2D),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Product product) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFF9A825), size: 18),
          const SizedBox(width: 4),
          Text(
            product.rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _statDivider(),
          Text(
            'Đã bán ${product.soldCount}',
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          _statDivider(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              product.category,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    width: 1,
    height: 16,
    color: Colors.grey.shade300,
  );

  Widget _buildVariantTile() {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _openSelectSheet(buyNow: false),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text(
                'Phân loại hàng',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  children: [
                    _ChipLabel(label: 'Size'),
                    _ChipLabel(label: 'Màu sắc'),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Product product) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFEE4D2D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Mô tả sản phẩm',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showMore
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              product.description,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                height: 1.6,
                fontSize: 14,
              ),
            ),
            secondChild: Text(
              product.description,
              style: const TextStyle(
                color: Colors.black87,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _showMore = !_showMore),
              icon: Icon(
                _showMore ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18,
                color: const Color(0xFFEE4D2D),
              ),
              label: Text(
                _showMore ? 'Thu gọn' : 'Xem thêm',
                style: const TextStyle(color: Color(0xFFEE4D2D)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          _BarIconBtn(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            onTap: () {},
          ),
          const SizedBox(width: 4),
          _BarIconBtn(
            icon: Icons.shopping_cart_outlined,
            label: 'Giỏ hàng',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEE4D2D), width: 1.5),
                  foregroundColor: const Color(0xFFEE4D2D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _openSelectSheet(buyNow: false),
                child: const Text(
                  'Thêm vào giỏ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 46,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEE4D2D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _openSelectSheet(buyNow: true),
                child: const Text(
                  'Mua ngay',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String label;
  const _ChipLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}

class _BarIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BarIconBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
