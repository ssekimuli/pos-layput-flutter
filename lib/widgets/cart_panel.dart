import 'package:flutter/material.dart';
import '../../../models/product.dart';

class CartPanel extends StatelessWidget {
  final List<Product> cart;
  final VoidCallback onToggle;
  final Function(int) onRemove;

  const CartPanel({
    super.key, 
    required this.cart, 
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    double total = cart.fold(0, (sum, item) => sum + item.price);

    return Container(
      width: 320,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Current Order", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: onToggle),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(cart[i].name),
                trailing: Text("\$${cart[i].price}"),
                leading: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onRemove(i),
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(onPressed: () {}, child: const Text("CHECKOUT")),
          ),
        ],
      ),
    );
  }
}