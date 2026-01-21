import 'package:flutter/material.dart';
import 'package:pos_desktop_ui/core/models/product.dart';

class PurchaseScreen extends StatelessWidget {
  final Product product;
  final VoidCallback onBack;
  final Function(Product) onAddToCart;

  const PurchaseScreen({
    super.key,
    required this.product,
    required this.onBack,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            label: const Text("Back to Gallery", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                    child: Center(child: Icon(Icons.coffee, size: 150, color: product.color)),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(product.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("\$${product.price}", style: const TextStyle(fontSize: 24, color: Colors.orange, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      const Text("Select Size", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(children: [_sizeChip("S"), _sizeChip("M"), _sizeChip("L")]),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () => onAddToCart(product),
                          child: const Text("Add to Order", style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _sizeChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
      child: Text(label),
    );
  }
}