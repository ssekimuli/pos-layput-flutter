import 'package:flutter/material.dart';
import '../../../models/product.dart';

class ProductScreen extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductSelected;
  final Function(int) onActionSelected;
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
    return Container(
      // Use a light background to make the white cards pop
      color: const Color(0xFFF4F7F9),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 1. Scrollable Grid Area
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,       // High density
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72, // Adjusts height for image + text
              ),
              itemCount: products.length,
              itemBuilder: (context, i) => _buildProductCard(context, products[i]),
            ),
          ),
          
          // 2. Fixed Bottom Actions (Prevents Overflow)
          _buildQuickActions(),
        ],
      ),
    );
  }
Widget _buildProductCard(BuildContext context, Product p) {
  const Color cardGrey = Color(0xFFF5F5F5);
  const Color sunflowerYellow = Color(0xFFFFCC4D);
  const Color priceTeal = Color(0xFF006070);
  const Color imageBg = Color(0xFFFFFBEB);

  return GestureDetector(
    // Logic: Double tap adds to cart, Single tap can be for details
    onDoubleTap: () {
      onProductSelected(p); // This calls your cart add logic in POSLayout
      
      // Visual feedback for the user
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${p.name} added to cart", 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: sunflowerYellow,
          duration: const Duration(milliseconds: 600),
          behavior: SnackBarBehavior.floating,
          width: 180,
        ),
      );
    },
    onTap: () {
      // Optional: Single tap for a detail view if needed later
    },
    child: Container(
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image Section (Reduced Margin to save space) ---
          Expanded(
            flex: 4, 
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(5), // Reduced margin
                  decoration: BoxDecoration(
                    color: imageBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(Icons.coffee_rounded, size: 22, color: priceTeal.withOpacity(0.15)),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: sunflowerYellow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Stock: 150",
                      style: TextStyle(
                        fontSize: 7.5, // Smallest font for density
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // --- Details Section (Compact Fonts) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6), // Tight bottom padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10, // Small Font
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${p.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: priceTeal,
                        fontWeight: FontWeight.w900,
                        fontSize: 11, // Small Font
                      ),
                    ),
                    // Visual indicator that it's addable
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: sunflowerYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 10, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildQuickActions() {
    return Container(
      height: 70, // Fixed height avoids overflow
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _actionButton(Icons.account_balance_wallet_outlined, "Drawer", () => onActionSelected(2)),
          _actionButton(Icons.history_toggle_off, "Shift", () => onActionSelected(3)),
          _actionButton(Icons.add_box_outlined, "New Item", () => onActionSelected(5)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}