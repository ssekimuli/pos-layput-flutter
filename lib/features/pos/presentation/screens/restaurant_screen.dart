import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';

class RestaurantScreen extends ConsumerWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> tables = [
      {'id': 1, 'name': 'Table 1', 'status': 'Available', 'capacity': 4},
      {'id': 2, 'name': 'Table 2', 'status': 'Occupied', 'capacity': 2},
      {'id': 3, 'name': 'Table 3', 'status': 'Reserved', 'capacity': 6},
      {'id': 4, 'name': 'Table 4', 'status': 'Available', 'capacity': 4},
      {'id': 5, 'name': 'Table 5', 'status': 'Occupied', 'capacity': 2},
      {'id': 6, 'name': 'Table 6', 'status': 'Available', 'capacity': 4},
      {'id': 7, 'name': 'Bar 1', 'status': 'Available', 'capacity': 1},
      {'id': 8, 'name': 'Bar 2', 'status': 'Available', 'capacity': 1},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Bar & Restaurant Orders",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              ElevatedButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.add), 
                label: const Text("Add Table"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatusIndicator(Colors.green, "Available"),
              const SizedBox(width: 20),
              _buildStatusIndicator(Colors.red, "Occupied"),
              const SizedBox(width: 20),
              _buildStatusIndicator(Colors.orange, "Reserved"),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                Color statusColor;
                switch (table['status']) {
                  case 'Available': statusColor = Colors.green; break;
                  case 'Occupied': statusColor = Colors.red; break;
                  case 'Reserved': statusColor = Colors.orange; break;
                  default: statusColor = Colors.grey;
                }

                return InkWell(
                  onTap: () => _handleTableSelection(context, ref, table),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
                    ),
                    color: statusColor.withOpacity(0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 32, color: statusColor),
                        const SizedBox(height: 10),
                        Text(
                          table['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text("Capacity: ${table['capacity']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "SELECT TABLE",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleTableSelection(BuildContext context, WidgetRef ref, Map<String, dynamic> table) {
    ref.read(cartProvider.notifier).resetCart(
      CartType.restaurant,
      targetId: table['name'],
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ordering for ${table['name']}. Please select products."),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildStatusIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
      ],
    );
  }
}
