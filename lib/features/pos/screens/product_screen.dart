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
  final List<Map<String, dynamic>> actions = [
    {
      "label": "Open Drawer", 
      "icon": Icons.account_balance_wallet, 
      "bg": Colors.black87, // Neutral
      "text": Colors.white
    },
    {
      "label": "End Shift", 
      "icon": Icons.logout, 
       "bg": Colors.black87, // Neutral
      "text": Colors.white
    },
    {
      "label": "Hold Order", 
      "icon": Icons.front_hand, 
       "bg": Colors.black87, // Neutral
      "text": Colors.white
    },
    {
      "label": "New Item", 
      "icon": Icons.add, 
      "bg": Colors.black87, // Neutral
      "text": Colors.white
    },
  ];

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ElevatedButton.icon(
            icon: Icon(action['icon'], size: 20, color: action['text']),
            label: Text(
              action['label'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: action['text'],
                fontSize: 14,
              ),
            ),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: action['bg'],
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}
}