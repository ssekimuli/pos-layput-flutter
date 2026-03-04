import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';
import 'package:intl/intl.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = ref.watch(activeOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Order Management",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: "All Orders"),
                  Tab(text: "Kitchen & Bar"),
                  Tab(text: "Reservations"),
                  Tab(text: "Room Service"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(activeOrders),
          _buildOrderList(activeOrders.where((o) => o.metadata.type == CartType.restaurant).toList()),
          _buildOrderList(activeOrders.where((o) => o.metadata.type == CartType.hotelBooking).toList()),
          _buildOrderList(activeOrders.where((o) => o.metadata.type == CartType.roomService).toList()),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<CartState> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text("No active orders found."));
    }

    return ListView.builder(
      primary: true,
      padding: const EdgeInsets.all(24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(CartState order) {
    final metadata = order.metadata;
    final total = order.items.fold(0.0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 1)));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _buildTypeBadge(metadata.type),
                const SizedBox(width: 12),
                Text(
                  metadata.displayName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildStatusChip(metadata.status),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                _infoColumn("Served By", metadata.servedBy),
                _infoColumn("Items", "${order.items.length}"),
                _infoColumn("Total Amount", "\$${total.toStringAsFixed(2)}"),
                _infoColumn("Time", DateFormat('HH:mm').format(metadata.createdAt)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _editOrder(order),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit / Add More"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue, elevation: 0),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _billOrder(order),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006070)),
                  child: const Text("Print Bill", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(CartType type) {
    IconData icon;
    Color color;
    switch (type) {
      case CartType.restaurant: icon = Icons.restaurant; color = Colors.orange; break;
      case CartType.hotelBooking: icon = Icons.hotel; color = Colors.blue; break;
      case CartType.roomService: icon = Icons.room_service; color = Colors.purple; break;
      default: icon = Icons.shopping_bag; color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.preparing: color = Colors.orange; break;
      case OrderStatus.served: color = Colors.blue; break;
      case OrderStatus.paid: color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _editOrder(CartState order) {
    ref.read(cartProvider.notifier).loadOrder(order);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Loaded ${order.metadata.displayName} to cart for editing.")),
    );
  }

  void _billOrder(CartState order) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Generating Bill"),
        content: Text("Printing receipt for ${order.metadata.displayName}..."),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
      ),
    );
  }
}
