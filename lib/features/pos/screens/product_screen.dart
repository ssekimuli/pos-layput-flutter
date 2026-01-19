import 'package:flutter/material.dart';
import 'package:pos_desktop_ui/models/product.dart';

class ProductScreen extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductSelected;
  final Color brandColor;

  const ProductScreen({
    super.key,
    required this.products,
    required this.onProductSelected,
    this.brandColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Category Tabs or Search could go here
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, 
                crossAxisSpacing: 16, 
                mainAxisSpacing: 16, 
                childAspectRatio: 0.85,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) => _buildProductCard(products[i]),
            ),
          ),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    return InkWell(
      onTap: () => onProductSelected(p),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.coffee, size: 48, color: p.color),
            ),
            const SizedBox(height: 12),
            Text(
              p.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "\$${p.price.toStringAsFixed(2)}",
              style: TextStyle(
                color: brandColor,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = ["Open Drawer", "End Shift", "Hold Order", "New Item"];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: actions.map((a) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black87),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            child: Text(a, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        )).toList(),
      ),
    );
  }
}