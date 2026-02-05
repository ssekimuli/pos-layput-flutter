import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Assuming your cart_provider has methods for clearCart, etc.
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';

class CartPanel extends ConsumerStatefulWidget {
  const CartPanel({super.key});

  @override
  ConsumerState<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends ConsumerState<CartPanel> {
  String _selectedPayment = "Cash";
  final double _taxRate = 0.10; // 10% Tax example
  final double _discount = 0.00; // Future: add discount logic

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    
    // Calculations
    double subtotal = cartItems.fold(0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 1)));
    double taxAmount = subtotal * _taxRate;
    double finalTotal = subtotal + taxAmount - _discount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Column(
        children: [
          _buildCartHeader(cartItems.length),
          _buildCustomerSelector(),
          const Divider(height: 1),
          
          // ITEM LIST
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.all(12),
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _buildCartItem(cartItems[index]),
                  ),
          ),

          // SUMMARY & CHECKOUT
          _buildCheckoutSummary(subtotal, taxAmount, finalTotal),
        ],
      ),
    );
  }

  // --- HEADER WITH QUICK ACTIONS ---
  Widget _buildCartHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 20, color: Color(0xFF006070)),
          const SizedBox(width: 8),
          Text("Current Order ($count)", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 22),
            tooltip: "Clear Cart",
            onPressed: () => _showClearDialog(),
          ),
        ],
      ),
    );
  }

  // --- CUSTOMER SELECTOR ---
  Widget _buildCustomerSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.person_add_alt_1, size: 18, color: Colors.blueGrey),
            SizedBox(width: 10),
            Text("Walk-in Customer", style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
            Spacer(),
            Icon(Icons.chevron_right, size: 18, color: Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  // --- ITEM ROW ---
  Widget _buildCartItem(dynamic item) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(item.name, 
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              Text("\$${(item.price * item.quantity).toStringAsFixed(2)}", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text("\$${item.price}/unit", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              const Spacer(),
              _qtyController(item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyController(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _circleBtn(Icons.remove, () => ref.read(cartProvider.notifier).decreaseQuantity(item)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          _circleBtn(Icons.add, () => ref.read(cartProvider.notifier).increaseQuantity(item)),
        ],
      ),
    );
  }

  // --- CHECKOUT AREA ---
  Widget _buildCheckoutSummary(double subtotal, double tax, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          _summaryRow("Subtotal", subtotal),
          _summaryRow("Tax (10%)", tax),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Payable", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("\$${total.toStringAsFixed(2)}", 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF006070))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: ["Cash", "Card", "QR"].map((m) => Expanded(child: _paymentOption(m))).toList(),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _actionButton("Hold Order", Colors.orange.shade50, Colors.orange.shade800, () {}),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _actionButton("CHECKOUT", const Color(0xFF006070), Colors.white, () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER UI COMPONENTS ---
  Widget _summaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text("\$${amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _paymentOption(String type) {
    bool isSelected = _selectedPayment == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006070) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF006070) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(type, style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color bg, Color text, VoidCallback press) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: press,
        child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback tap) {
    return IconButton(
      onPressed: tap,
      icon: Icon(icon, size: 14),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  void _showClearDialog() {
    // Implement clear cart logic here
  }
  

  Widget _buildEmptyState() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey),
        SizedBox(height: 10),
        Text("No items in cart", style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}