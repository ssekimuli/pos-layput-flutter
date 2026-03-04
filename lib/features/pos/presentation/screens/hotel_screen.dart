import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';

class HotelScreen extends ConsumerWidget {
  const HotelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> rooms = [
      {'id': 1, 'number': '101', 'type': 'Standard', 'status': 'Available', 'price': 80.0},
      {'id': 2, 'number': '102', 'type': 'Standard', 'status': 'Occupied', 'price': 80.0},
      {'id': 3, 'number': '103', 'type': 'Deluxe', 'status': 'Available', 'price': 120.0},
      {'id': 4, 'number': '104', 'type': 'Deluxe', 'status': 'Occupied', 'price': 120.0},
      {'id': 5, 'number': '201', 'type': 'Suite', 'status': 'Available', 'price': 200.0},
      {'id': 6, 'number': '202', 'type': 'Suite', 'status': 'Maintenance', 'price': 200.0},
      {'id': 7, 'number': '203', 'type': 'Suite', 'status': 'Available', 'price': 200.0},
      {'id': 8, 'number': '204', 'type': 'Standard', 'status': 'Available', 'price': 80.0},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hotel & Room Management",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatusIndicator(Colors.green, "Available"),
              const SizedBox(width: 20),
              _buildStatusIndicator(Colors.red, "Occupied"),
              const SizedBox(width: 20),
              _buildStatusIndicator(Colors.blueGrey, "Maintenance"),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                Color statusColor;
                switch (room['status']) {
                  case 'Available': statusColor = Colors.green; break;
                  case 'Occupied': statusColor = Colors.red; break;
                  case 'Maintenance': statusColor = Colors.blueGrey; break;
                  default: statusColor = Colors.grey;
                }

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: statusColor.withOpacity(0.3)),
                  ),
                  color: statusColor.withOpacity(0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.king_bed, size: 32, color: statusColor),
                      const SizedBox(height: 10),
                      Text(
                        "Room ${room['number']}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text("${room['type']} - \$${room['price']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _smallBtn("BOOK", Colors.blue, () => _handleBooking(context, ref, room)),
                          const SizedBox(width: 8),
                          _smallBtn("SERVICE", Colors.orange, () => _handleRoomService(context, ref, room)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleBooking(BuildContext context, WidgetRef ref, Map<String, dynamic> room) {
    ref.read(cartProvider.notifier).resetCart(
      CartType.hotelBooking,
      targetId: room['number'],
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Creating booking for Room ${room['number']}")),
    );
  }

  void _handleRoomService(BuildContext context, WidgetRef ref, Map<String, dynamic> room) {
    ref.read(cartProvider.notifier).resetCart(
      CartType.roomService,
      targetId: room['number'],
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Room service for Room ${room['number']}. Select items.")),
    );
  }

  Widget _smallBtn(String label, Color color, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatusIndicator(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
      ],
    );
  }
}
