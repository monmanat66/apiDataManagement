import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  double _tileAspectRatio(double width) {
    if (width < 360) return 0.56;
    if (width < 520) return 0.62;
    if (width < 800) return 0.70;
    return 0.80;
  }

  int _crossAxisCount(double width) {
    if (width < 440) return 2;
    if (width < 800) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 520;
    final crossAxisCount = _crossAxisCount(width);
    final aspect = _tileAspectRatio(width);

    // Base widgets (no Expanded in Column case)
    final searchFieldWidget = TextField(
      decoration: const InputDecoration(
        hintText: 'ค้นหา... (ชื่อ/คำอธิบาย)',
        prefixIcon: Icon(Icons.search),
      ),
      onSubmitted: (v) => context.read<ProductProvider>().setQuery(v),
    );

    final categoryFieldWidget = DropdownButtonFormField<String>(
      isExpanded: true,
      value: prov.selectedCategory.isEmpty ? '' : prov.selectedCategory,
      items: [
        const DropdownMenuItem(
            value: '',
            child: Text('ทุกหมวดหมู่', overflow: TextOverflow.ellipsis)),
        ...prov.categories
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
      ],
      onChanged: (v) => context.read<ProductProvider>().setCategory(v ?? ''),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.category),
      ),
    );

    Widget filters(BuildContext ctx) {
      if (isNarrow) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            searchFieldWidget,
            const SizedBox(height: 12),
            categoryFieldWidget,
          ],
        );
      } else {
        return Row(
          children: [
            Expanded(flex: 2, child: searchFieldWidget),
            const SizedBox(width: 12),
            Expanded(child: categoryFieldWidget),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FakeStore Admin'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => context.read<ProductProvider>().setSort(v),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'asc', child: Text('เรียงราคา ⬆')),
              PopupMenuItem(value: 'desc', child: Text('เรียงราคา ⬇')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: filters(context),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<ProductProvider>().load(),
              child: prov.items.isEmpty
                  ? const Center(child: Text('ไม่พบข้อมูล'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: aspect,
                      ),
                      itemCount: prov.items.length,
                      itemBuilder: (ctx, i) => ProductCard(product: prov.items[i]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
      ),
    );
  }
}
