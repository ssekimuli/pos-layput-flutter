import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';

class CartPanel extends ConsumerStatefulWidget {
  const CartPanel({super.key});

  @override
  ConsumerState<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends ConsumerState<CartPanel> {
  String _selectedPayment = "Cash";
  final double _taxRate = 0.10;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.items;
    final metadata = cartState.metadata;
    
    double subtotal = cartItems.fold(0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 1)));
    double taxAmount = subtotal * _taxRate;
    double finalTotal = subtotal + taxAmount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Column(
        children: [
          _buildCartHeader(metadata),
          _buildContextBadge(metadata),
          const Divider(height: 1),
          
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

          _buildCheckoutSummary(subtotal, taxAmount, finalTotal, metadata),
        ],
      ),
    );
  }

  Widget _buildCartHeader(CartMetadata metadata) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Icon(_getIconForType(metadata.type), size: 20, color: const Color(0xFF006070)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metadata.displayName, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(_getSubtitleForType(metadata.type), 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 22),
            onPressed: () => ref.read(cartProvider.notifier).clearCart(),
          ),
        ],
      ),
    );
  }

  Widget _buildContextBadge(CartMetadata metadata) {
    if (metadata.type == CartType.shop) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 14, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            "Finalizing order for ${metadata.targetId}",
            style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(CartType type) {
    switch (type) {
      case CartType.shop: return Icons.shopping_bag;
      case CartType.restaurant: return Icons.restaurant;
      case CartType.hotelBooking: return Icons.hotel;
      case CartType.roomService: return Icons.room_service;
    }
  }

  String _getSubtitleForType(CartType type) {
    switch (type) {
      case CartType.shop: return "Standard Retail Sale";
      case CartType.restaurant: return "Dine-in Order";
      case CartType.hotelBooking: return "New Reservation";
      case CartType.roomService: return "Room Order";
    }
  }

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
              Text("\$${((item.price ?? 0) * (item.quantity ?? 1)).toStringAsFixed(2)}", 
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

  Widget _buildCheckoutSummary(double subtotal, double tax, double total, CartMetadata metadata) {
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
            children: [
              Expanded(
                flex: 2,
                child: _actionButton("CANCEL", Colors.red.shade50, Colors.red.shade800, () {
                  ref.read(cartProvider.notifier).resetCart(CartType.shop);
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _actionButton(
                  _getCheckoutLabel(metadata.type), 
                  const Color(0xFF006070), 
                  Colors.white, 
                  () => _processCheckout(total)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCheckoutLabel(CartType type) {
    switch (type) {
      case CartType.hotelBooking: return "CONFIRM BOOKING";
      case CartType.roomService: return "SEND TO ROOM";
      case CartType.restaurant: return "PLACE ORDER";
      default: return "COMPLETE SALE";
    }
  }

  void _processCheckout(double total) {
    // Show success dialog
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Success"),
        content: Text("Order processed successfully for \$${total.toStringAsFixed(2)}"),
        actions: [
          TextButton(onPressed: () {
            ref.read(cartProvider.notifier).resetCart(CartType.shop);
            Navigator.pop(c);
          }, child: const Text("Done"))
        ],
      )
    );
  }

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
        child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 11)),
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

  Widget _buildEmptyState() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey),
        SizedBox(height: 10),
        Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}
