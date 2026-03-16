import 'package:flutter/foundation.dart';
import 'package:th4/models/product.dart';
import 'package:th4/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  final List<Product> _allProducts = [];
  final List<Product> _products = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  static const int _pageSize = 8;
  int _page = 1;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> initIfNeeded() async {
    if (_products.isEmpty && !_isLoading) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _service.fetchProducts();
      _allProducts
        ..clear()
        ..addAll(fetched);

      _products.clear();
      _page = 1;
      _hasMore = true;
      _appendPage();
    } catch (e) {
      _error = 'Không thể tải sản phẩm. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 350));
    _appendPage();

    _isLoadingMore = false;
    notifyListeners();
  }

  void _appendPage() {
    final start = (_page - 1) * _pageSize;
    if (start >= _allProducts.length) {
      _hasMore = false;
      return;
    }

    final end = (start + _pageSize).clamp(0, _allProducts.length);
    _products.addAll(_allProducts.sublist(start, end));
    _page += 1;
    _hasMore = end < _allProducts.length;
  }
}
