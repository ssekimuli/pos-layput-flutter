import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern soft slate background
      body: SingleChildScrollView(
        primary: true,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION ---
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Executive Dashboard",
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      "Monitor your business performance in real-time.",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(),
                _buildDateRangePicker(),
              ],
            ),
            const SizedBox(height: 32),

            // --- KPI METRIC CARDS ---
            Row(
              children: [
                _buildKPICard("Total Revenue", "\$42,850.00", "+12.5%", Icons.payments, Colors.blue),
                const SizedBox(width: 20),
                _buildKPICard("Total Sales", "1,240", "+8.2%", Icons.shopping_cart, Colors.green),
                const SizedBox(width: 20),
                _buildKPICard("Room Occupancy", "85%", "+5.4%", Icons.hotel, Colors.purple),
                const SizedBox(width: 20),
                _buildKPICard("Table Status", "12/20", "Active", Icons.restaurant, Colors.orange),
              ],
            ),
            const SizedBox(height: 32),

            // --- ANALYTICS & ACTIVITY ROW ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sales Trend Chart (Mockup)
                Expanded(
                  flex: 2,
                  child: _buildChartContainer("Sales Trend (Last 7 Days)"),
                ),
                const SizedBox(width: 24),
                // Recent Activity
                Expanded(
                  flex: 1,
                  child: _buildRecentActivity(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- QUICK ACTION MODULES ---
            const Text(
              "Management Modules",
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
          SizedBox(width: 8),
          Text("Mar 01 - Mar 07, 2026", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, String change, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(change, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContainer(String title) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          // Visual Mockup of a Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final heights = [100.0, 150.0, 120.0, 200.0, 180.0, 250.0, 220.0];
              return Container(
                width: 40,
                height: heights[index],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue, Colors.blue.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                .map((d) => Text(d, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)))
                .toList(),
          )
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildActivityItem("New Booking", "Room 102 - John Doe", "2m ago", Colors.blue),
                _buildActivityItem("Order Placed", "Table 5 - \$45.00", "15m ago", Colors.orange),
                _buildActivityItem("Payment Received", "Inv #8824 - \$120.00", "1h ago", Colors.green),
                _buildActivityItem("Low Stock Alert", "Heineken Beer 330ml", "3h ago", Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String sub, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(sub, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    final modules = [
      {"name": "HOTEL", "icon": Icons.hotel, "color": Colors.blue, "index": 15},
      {"name": "BAR", "icon": Icons.local_bar, "color": Colors.orange, "index": 14},
      {"name": "SHOP", "icon": Icons.shopping_bag, "color": Colors.green, "index": 0},
      {"name": "STOCK", "icon": Icons.inventory_2, "color": Colors.blue, "index": 2},
      {"name": "STAFF", "icon": Icons.badge, "color": Colors.indigo, "index": 10},
      {"name": "FINANCE", "icon": Icons.account_balance_wallet, "color": Colors.pink, "index": 11},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final m = modules[index];
        return InkWell(
          onTap: () => widget.onNavigate?.call(m['index'] as int),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m['icon'] as IconData, color: m['color'] as Color, size: 24),
                const SizedBox(height: 8),
                Text(m['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}
