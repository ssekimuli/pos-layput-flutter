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
  String _selectedPayment = "Cash"; // State for payment method

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    
    // Calculations
    double subtotal = cartItems.fold(0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 1)));
    double discount = 0.0; // Placeholder for discount logic
    double total = subtotal - discount;
    double balance = _receivedAmount > 0 ? _receivedAmount - total : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Modern off-white background
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          _buildHeader(cartItems.length),
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) => _buildModernCartItem(cartItems[index]),
                  ),
          ),
          _buildCheckoutSection(total, balance),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text("Current Order", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF006070).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("$count items", 
              style: const TextStyle(color: Color(0xFF006070), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text("Your cart is empty", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
      ],
    );
  }

  Widget _buildModernCartItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
                      const SizedBox(height: 4),
                      Text("\$${item.price} per unit", 
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                Text("\$${(item.price * (item.quantity ?? 1)).toStringAsFixed(2)}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF006070))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // DELETE BUTTON
                InkWell(
                  onTap: () => ref.read(cartProvider.notifier).removeProduct(item),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  ),
                ),
                const Spacer(),
                // QUANTITY STEPPER
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _qtyBtn(Icons.remove, () => ref.read(cartProvider.notifier).decreaseQuantity(item)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text("${item.quantity ?? 1}", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      _qtyBtn(Icons.add, () => ref.read(cartProvider.notifier).increaseQuantity(item)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(double total, double balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(
        children: [
          // DISCOUNT SECTION
          InkWell(
            onTap: () {}, // Add Discount Dialog
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.orange.shade50,
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_offer_outlined, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Apply Promo Code", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.orange),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // PAYMENT METHODS
          const Align(alignment: Alignment.centerLeft, 
            child: Text("Payment Method", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
          const SizedBox(height: 10),
          Row(
            children: [
              _payChip("Cash", Icons.payments_outlined),
              const SizedBox(width: 8),
              _payChip("Card", Icons.credit_card_outlined),
              const SizedBox(width: 8),
              _payChip("Online", Icons.qr_code_scanner_outlined),
            ],
          ),
          const SizedBox(height: 20),

          // AMOUNTS
          _rowAmount("Subtotal", "\$${total.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          _rowAmount("Total Amount", "\$${total.toStringAsFixed(2)}", isBold: true, fontSize: 20, color: const Color(0xFF006070)),
          const Divider(height: 32),

          // CHECKOUT BUTTON
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006070),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: total > 0 ? () {} : null,
              child: const Text("PROCEED TO CHECKOUT", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _payChip(String label, IconData icon) {
    bool isSelected = _selectedPayment == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPayment = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF006070) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFF006070) : Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.bold, 
                color: isSelected ? Colors.white : Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowAmount(String label, String value, {bool isBold = false, Color? color, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        Text(value, style: TextStyle(
          fontSize: fontSize, 
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? const Color(0xFF1E293B)
        )),
      ],
    );
  }
}