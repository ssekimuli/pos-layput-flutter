import 'package:flutter/material.dart';
import 'package:pos_desktop_ui/models/product.dart';

class ProductScreen extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductSelected;
  final Function(int) onActionSelected; // Callback to switch layout index
  final Color brandColor;

  const ProductScreen({
    super.key,
    required this.products,
    required this.onProductSelected,
    required this.onActionSelected,
    this.brandColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          // Index 2 = Receipt/Drawer, Index 3 = Reports, Index 5 = Stock
          _actionButton(Icons.account_balance_wallet, "Open Drawer", () => onActionSelected(2)),
          _actionButton(Icons.logout, "End Shift", () => onActionSelected(3)),
          _actionButton(Icons.add, "New Item", () => onActionSelected(5)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}