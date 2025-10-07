import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? edit;
  const ProductFormScreen({super.key, this.edit});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _price;
  late TextEditingController _image;
  late TextEditingController _description;
  String _category = '';

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    _title = TextEditingController(text: e?.title ?? '');
    _price = TextEditingController(text: e?.price.toString() ?? '');
    _image = TextEditingController(text: e?.image ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? '';
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _image.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();
    final isEdit = widget.edit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'แก้ไขสินค้า #${widget.edit!.id}' : 'เพิ่มสินค้า')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _title,
                          decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'กรอกชื่อ' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _price,
                          decoration: const InputDecoration(labelText: 'ราคา (USD)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            final x = double.tryParse(v ?? '');
                            if (x == null || x < 0) return 'กรอกราคาให้ถูกต้อง';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _category.isEmpty ? null : _category,
                          items: [
                            ...prov.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          ],
                          onChanged: (v) => setState(() => _category = v ?? ''),
                          decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                          validator: (v) => (v == null || v.isEmpty) ? 'เลือกหมวดหมู่' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _image,
                          decoration: const InputDecoration(labelText: 'ลิงก์รูปภาพ (URL)'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _description,
                          maxLines: 4,
                          decoration: const InputDecoration(labelText: 'คำอธิบาย'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 160,
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _image.text.isEmpty
                                ? const Icon(Icons.image, size: 48)
                                : Image.network(_image.text, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _image.text = 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/600/600';
                            });
                          },
                          child: const Text('สุ่มรูปภาพ'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ยกเลิก'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (!_form.currentState!.validate()) return;
                        final p = Product(
                          id: widget.edit?.id,
                          title: _title.text.trim(),
                          price: double.parse(_price.text),
                          description: _description.text.trim(),
                          category: _category,
                          image: _image.text.trim().isEmpty
                              ? 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/600/600'
                              : _image.text.trim(),
                        );
                        if (isEdit) {
                          await context.read<ProductProvider>().update(p);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('อัปเดตสินค้าแล้ว')));
                            Navigator.pop(context);
                          }
                        } else {
                          await context.read<ProductProvider>().add(p);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เพิ่มสินค้าแล้ว')));
                            Navigator.pop(context);
                          }
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('บันทึก'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
