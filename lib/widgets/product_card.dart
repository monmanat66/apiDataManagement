import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../screens/product_form_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      visualDensity: VisualDensity.compact,
    );
    final outlineStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      visualDensity: VisualDensity.compact,
    );

    return Card(
      elevation: 0.5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductFormScreen(edit: product),
          ));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Make image flexible
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(child: Chip(label: Text(product.category, overflow: TextOverflow.ellipsis))),
                        const Spacer(),
                        Text('\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: outlineStyle,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ProductFormScreen(edit: product),
                              ));
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('แก้ไข'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            style: buttonStyle.copyWith(backgroundColor: const WidgetStatePropertyAll(Colors.red)),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('ยืนยันการลบ'),
                                  content: Text('ลบสินค้า #${product.id}?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
                                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await context.read<ProductProvider>().remove(product);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('ลบสินค้าแล้ว')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('ลบ'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
