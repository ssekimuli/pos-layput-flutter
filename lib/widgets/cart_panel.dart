import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.shopping_basket_outlined, color: Color(0xFF006070)),
                SizedBox(width: 10),
                Text(
                  "Current Order",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("No items in cart", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        elevation: 0,
                        color: const Color(0xFFF4F7F9),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("\$${item.price}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => ref.read(cartProvider.notifier).removeProduct(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildSummary(cartItems),
        ],
      ),
    );
  }

  Widget _buildSummary(List cartItems) {
    // Basic math for total
    double total = cartItems.fold(0, (sum, item) => sum + (item.price ?? 0));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontSize: 16, color: Colors.black54)),
              Text("\$${total.toStringAsFixed(2)}", 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF006070))),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006070),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: cartItems.isEmpty ? null : () {
              // Action for payment
            },
            child: const Text("Place Order", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}