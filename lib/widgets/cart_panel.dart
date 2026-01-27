import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';

class CartPanel extends ConsumerStatefulWidget {
  const CartPanel({super.key});

  @override
  ConsumerState<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends ConsumerState<CartPanel> {
  final TextEditingController _amountController = TextEditingController();
  double _receivedAmount = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    double total = cartItems.fold(0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 1)));
    double balance = _receivedAmount > 0 ? _receivedAmount - total : 0.0;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Cart Empty", style: TextStyle(color: Colors.grey, fontSize: 12)))
                : ListView.builder(
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
          ),
          _buildCheckoutSection(total, balance),
        ],
      ),
    );
  }

  Widget _buildCartItem(dynamic item) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF4F7F9),
      margin: const EdgeInsets.only(bottom: 6), // Reduced margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Smaller padding
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.name, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), // Smaller font
                ),
                Text("\$${(item.price * (item.quantity ?? 1)).toStringAsFixed(2)}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text("\$${item.price} ea", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const Spacer(),
                _quantityButton(Icons.remove, () => ref.read(cartProvider.notifier).decreaseQuantity(item)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text("${item.quantity ?? 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                _quantityButton(Icons.add, () => ref.read(cartProvider.notifier).increaseQuantity(item)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(double total, double balance) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          _rowAmount("Subtotal", "\$${total.toStringAsFixed(2)}", isBold: true, fontSize: 13),
          const SizedBox(height: 8),
          SizedBox(
            height: 40, // Fixed small height for input
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13), // Smaller input text
              decoration: InputDecoration(
                isDense: true, // Makes the input compact
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                labelText: "Received",
                labelStyle: const TextStyle(fontSize: 12),
                prefixText: "\$ ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                setState(() {
                  _receivedAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          _rowAmount("Balance", "\$${balance.toStringAsFixed(2)}", 
              color: Colors.green.shade700, isBold: true, fontSize: 14),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006070),
              minimumSize: const Size(double.infinity, 40), // Shorter button
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: (total > 0 && _receivedAmount >= total) ? () {
              // Action logic
            } : null,
            child: const Text("COMPLETE", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2), // Smaller button area
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300), 
          borderRadius: BorderRadius.circular(4)
        ),
        child: Icon(icon, size: 14), // Smaller icon
      ),
    );
  }

  Widget _rowAmount(String label, String value, {bool isBold = false, Color? color, double fontSize = 12}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.black54, fontSize: fontSize)),
        Text(value, style: TextStyle(
          fontSize: fontSize, 
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black87
        )),
      ],
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(12.0), // Reduced header padding
      child: Row(
        children: [
          Icon(Icons.shopping_cart_checkout, color: Color(0xFF006070), size: 18),
          SizedBox(width: 8),
          Text("Summary", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}