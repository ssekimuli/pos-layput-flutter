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
    borderRadius: BorderRadius.circular(12), // Slightly smaller radius
    child: Container(
      padding: const EdgeInsets.all(8), // Add internal padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4, // Reduced blur
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced from 12
            decoration: BoxDecoration(
              color: p.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.coffee, size: 28, color: p.color), // Reduced from 48
          ),
          const SizedBox(height: 8), // Reduced from 12
          Text(
            p.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12, // Reduced from 14
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "\$${p.price.toStringAsFixed(2)}",
            style: TextStyle(
              color: brandColor,
              fontWeight: FontWeight.w900,
              fontSize: 13, // Reduced from 16
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12), // Reduced vertical padding
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
      padding: const EdgeInsets.only(right: 8), // Reduced spacing between buttons
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 16, color: Colors.white), // Smaller icon (16 instead of 20)
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white, 
            fontSize: 12, // Smaller font (12 instead of 14)
          ),
        ),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          elevation: 1,
          // Significantly reduced padding to make the button smaller
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Sharper corners for a compact look
          ),
        ),
      ),
    );
  }
}