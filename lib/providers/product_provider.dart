import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _all = [];
  List<String> _categories = [];
  String _query = '';
  String _selectedCategory = '';
  String _sort = 'asc';

  List<Product> get items {
    final q = _query.trim().toLowerCase();
    List<Product> list = _all.where((p) {
      final hit = p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      final catOk = _selectedCategory.isEmpty || p.category == _selectedCategory;
      return hit && catOk;
    }).toList();
    list.sort((a, b) =>
        _sort == 'desc' ? b.price.compareTo(a.price) : a.price.compareTo(b.price));
    return list;
  }

  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get sort => _sort;

  Future<void> load() async {
    _categories = await ApiService.fetchCategories();
    _all = await ApiService.fetchProducts(sort: _sort);
    notifyListeners();
  }

  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  void setCategory(String v) {
    _selectedCategory = v;
    notifyListeners();
  }

  Future<void> setSort(String s) async {
    _sort = (s == 'desc') ? 'desc' : 'asc';
    _all = await ApiService.fetchProducts(sort: _sort);
    notifyListeners();
  }

  Future<void> add(Product p) async {
    final created = await ApiService.createProduct(p);
    _all.insert(0, created);
    notifyListeners();
  }

  Future<void> update(Product p) async {
    final updated = await ApiService.updateProduct(p);
    final idx = _all.indexWhere((e) => e.id == updated.id);
    if (idx >= 0) _all[idx] = updated;
    notifyListeners();
  }

  Future<void> remove(Product p) async {
    if (p.id == null) return;
    await ApiService.deleteProduct(p.id!);
    _all.removeWhere((e) => e.id == p.id);
    notifyListeners();
  }
}
