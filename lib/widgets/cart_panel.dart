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
  String _selectedPayment = "Cash";

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    double total = cartItems.fold(0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 1)));

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildCompactHeader(cartItems.length),
          
          // SECTION 1: LONGER ITEM LIST (Flex 3)
          Expanded(
            flex: 3, 
            child: cartItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) => _buildUltraCompactItem(cartItems[index]),
                  ),
          ),

          // SECTION 2: SMALLER CHECKOUT AREA (Flex 1 or fixed)
          _buildCompactCheckout(total),
        ],
      ),
    );
  }

  // --- COMPACT ITEM (More height for the list) ---
  Widget _buildUltraCompactItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Small delete
          InkWell(
            onTap: () => ref.read(cartProvider.notifier).removeProduct(item),
            child: const Icon(Icons.close, size: 16, color: Colors.redAccent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(item.name, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          // Small Stepper
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _miniQtyBtn(Icons.remove, () => ref.read(cartProvider.notifier).decreaseQuantity(item)),
                Text("${item.quantity}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                _miniQtyBtn(Icons.add, () => ref.read(cartProvider.notifier).increaseQuantity(item)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text("\$${(item.price * item.quantity).toStringAsFixed(2)}", 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- COMPACT CHECKOUT (Saves vertical space) ---
  Widget _buildCompactCheckout(double total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Keep this small
        children: [
          // Payment Selector in one line
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["Cash", "Card", "Online"].map((m) => _smallPayChip(m)).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text("\$${total.toStringAsFixed(2)}", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006070))),
            ],
          ),
          const SizedBox(height: 8),
          // Compact Button
          SizedBox(
            width: double.infinity,
            height: 38, // Small height
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006070),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {},
              child: const Text("PAY NOW", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(icon, size: 12),
      ),
    );
  }

  Widget _smallPayChip(String label) {
    bool isSelected = _selectedPayment == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = label),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006070) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87, 
          fontSize: 11, 
          fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCompactHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Cart", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text("$count Items", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("Cart is empty", style: TextStyle(fontSize: 12, color: Colors.grey)));
}