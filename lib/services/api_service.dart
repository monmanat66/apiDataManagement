import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String base = 'https://fakestoreapi.com';

  static Future<List<String>> fetchCategories() async {
    final res = await http.get(Uri.parse('$base/products/categories'));
    if (res.statusCode != 200) throw Exception('โหลดหมวดหมู่ไม่สำเร็จ');
    final List data = jsonDecode(res.body);
    return data.cast<String>();
  }

  static Future<List<Product>> fetchProducts({String sort = 'asc'}) async {
    final res = await http.get(Uri.parse('$base/products?sort=$sort'));
    if (res.statusCode != 200) throw Exception('โหลดสินค้าล้มเหลว');
    final List data = jsonDecode(res.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  static Future<Product> createProduct(Product p) async {
    final res = await http.post(
      Uri.parse('$base/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(p.toJson()),
    );
    if (res.statusCode >= 400) throw Exception('สร้างสินค้าไม่สำเร็จ');
    final Map<String, dynamic> data = jsonDecode(res.body);
    return Product.fromJson({...p.toJson(), 'id': data['id']});
  }

  static Future<Product> updateProduct(Product p) async {
    if (p.id == null) throw Exception('ไม่มีไอดีสินค้า');
    final res = await http.put(
      Uri.parse('$base/products/${p.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(p.toJson()),
    );
    if (res.statusCode >= 400) throw Exception('อัปเดตสินค้าไม่สำเร็จ');
    final Map<String, dynamic> _ = jsonDecode(res.body);
    return p; // API เป็น mock
  }

  static Future<void> deleteProduct(int id) async {
    final res = await http.delete(Uri.parse('$base/products/$id'));
    if (res.statusCode >= 400) throw Exception('ลบสินค้าไม่สำเร็จ');
  }
}
