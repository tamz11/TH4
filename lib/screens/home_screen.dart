import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:th4/providers/product_provider.dart';
import 'package:th4/screens/cart_screen.dart';
import 'package:th4/widgets/cart_badge_icon.dart';
import 'package:th4/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _bannerIndex = 0;
  bool _isCollapsed = false;

  final List<String> _banners = const [
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=1200',
    'https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=1200',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1200',
  ];

  final List<Map<String, dynamic>> _categories = const [
    {'icon': Icons.checkroom, 'name': 'Fashion'},
    {'icon': Icons.phone_android, 'name': 'Phone'},
    {'icon': Icons.face_retouching_natural, 'name': 'Beauty'},
    {'icon': Icons.kitchen, 'name': 'Home'},
    {'icon': Icons.sports_basketball, 'name': 'Sport'},
    {'icon': Icons.chair, 'name': 'Furniture'},
    {'icon': Icons.pets, 'name': 'Pet'},
    {'icon': Icons.menu_book, 'name': 'Book'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initIfNeeded();
    });

    _scrollController.addListener(_onScroll);
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_bannerController.hasClients) {
        return;
      }
      _bannerIndex = (_bannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        _bannerIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final collapsed = _scrollController.offset > 36;
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }

    final provider = context.read<ProductProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      provider.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: provider.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 128,
                  backgroundColor:
                      _isCollapsed ? const Color(0xFFEE4D2D) : Colors.transparent,
                  title: const Text('TH4 - Nhóm [Số nhóm]'),
                  foregroundColor: Colors.white,
                  elevation: _isCollapsed ? 2 : 0,
                  actions: [
                    CartBadgeIcon(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF35A3F), Color(0xFFEE4D2D)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 78, 16, 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 10),
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Tìm sản phẩm', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 150,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: _bannerController,
                                onPageChanged: (index) => setState(() => _bannerIndex = index),
                                itemCount: _banners.length,
                                itemBuilder: (_, i) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(_banners[i], fit: BoxFit.cover),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(_banners.length, (i) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: _bannerIndex == i ? 16 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _bannerIndex == i
                                            ? const Color(0xFFEE4D2D)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Danh mục',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 130,
                          child: GridView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemBuilder: (_, index) {
                              final category = _categories[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(category['icon'] as IconData,
                                        color: const Color(0xFFEE4D2D)),
                                    const SizedBox(height: 4),
                                    Text(
                                      category['name'] as String,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gợi ý hôm nay',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.error != null)
                  SliverFillRemaining(
                    child: Center(child: Text(provider.error!)),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.63,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = provider.products[index];
                          return ProductCard(product: product);
                        },
                        childCount: provider.products.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: provider.isLoadingMore
                          ? const CircularProgressIndicator()
                          : Text(
                              provider.hasMore
                                  ? 'Kéo xuống để tải thêm'
                                  : 'Đã hết sản phẩm',
                              style: const TextStyle(color: Colors.grey),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
