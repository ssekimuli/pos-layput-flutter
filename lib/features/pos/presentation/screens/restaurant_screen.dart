import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop_ui/core/models/product.dart';
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';
import 'package:pos_desktop_ui/core/providers/table_provider.dart';
import 'package:uuid/uuid.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  const RestaurantScreen({super.key});

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTables = ref.watch(tableProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Table Management",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showTableCRUDDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add Table"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: "Regular"),
                  Tab(text: "VIP"),
                  Tab(text: "Outdoor"),
                  Tab(text: "Bar"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTableGrid(allTables.where((t) => t.group == TableGroup.regular).toList()),
          _buildTableGrid(allTables.where((t) => t.group == TableGroup.vip).toList()),
          _buildTableGrid(allTables.where((t) => t.group == TableGroup.outdoor).toList()),
          _buildTableGrid(allTables.where((t) => t.group == TableGroup.bar).toList()),
        ],
      ),
    );
  }

  Widget _buildTableGrid(List<TableModel> tables) {
    if (tables.isEmpty) return const Center(child: Text("No tables in this group."));

    return GridView.builder(
      primary: true,
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return _TableCard(table: table);
      },
    );
  }

  void _showTableCRUDDialog(BuildContext context, [TableModel? existingTable]) {
    final numberController = TextEditingController(text: existingTable?.number ?? "");
    final capacityController = TextEditingController(text: (existingTable?.capacity ?? 4).toString());
    TableGroup selectedGroup = existingTable?.group ?? TableGroup.regular;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingTable == null ? "Add New Table" : "Edit Table ${existingTable.number}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: numberController, decoration: const InputDecoration(labelText: "Table Number/Name")),
              TextField(controller: capacityController, decoration: const InputDecoration(labelText: "Capacity"), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButton<TableGroup>(
                value: selectedGroup,
                isExpanded: true,
                onChanged: (val) => setDialogState(() => selectedGroup = val!),
                items: TableGroup.values.map((g) => DropdownMenuItem(value: g, child: Text(g.name.toUpperCase()))).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            if (existingTable != null)
              TextButton(
                onPressed: () {
                  ref.read(tableProvider.notifier).deleteTable(existingTable.id);
                  Navigator.pop(context);
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: () {
                final table = TableModel(
                  id: existingTable?.id ?? const Uuid().v4(),
                  number: numberController.text,
                  capacity: int.tryParse(capacityController.text) ?? 4,
                  group: selectedGroup,
                  status: existingTable?.status ?? TableStatus.available,
                );
                if (existingTable == null) {
                  ref.read(tableProvider.notifier).addTable(table);
                } else {
                  ref.read(tableProvider.notifier).updateTable(table);
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCard extends ConsumerWidget {
  final TableModel table;
  const _TableCard({required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    IconData statusIcon = Icons.restaurant;
    
    switch (table.status) {
      case TableStatus.available: statusColor = Colors.green; break;
      case TableStatus.occupied: statusColor = Colors.red; statusIcon = Icons.people; break;
      case TableStatus.reserved: statusColor = Colors.orange; statusIcon = Icons.event_available; break;
      case TableStatus.cleaning: statusColor = Colors.blueGrey; statusIcon = Icons.cleaning_services; break;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onLongPress: () {
          // Trigger edit via parent state if needed, or simple status toggle for demo
        },
        onTap: () => _handleTableInteraction(context, ref),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
            boxShadow: [BoxShadow(color: statusColor.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, size: 36, color: statusColor),
              const SizedBox(height: 12),
              Text(
                "Table ${table.number}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
              ),
              Text(
                "${table.capacity} Seats",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  table.status.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTableInteraction(BuildContext context, WidgetRef ref) {
    if (table.status == TableStatus.cleaning) {
      ref.read(tableProvider.notifier).updateStatus(table.id, TableStatus.available);
      return;
    }

    // Load or Start new order
    ref.read(cartProvider.notifier).updateType(
      CartType.restaurant,
      targetId: "Table ${table.number}",
    );

    // If table is available, we add a placeholder and mark it occupied
    if (table.status == TableStatus.available) {
      ref.read(tableProvider.notifier).updateStatus(table.id, TableStatus.occupied);
      ref.read(cartProvider.notifier).addProduct(
        Product(
          id: 'TBL-${table.id}',
          name: "Table ${table.number} Service",
          price: 0.0,
          color: Colors.orange,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Serving Table ${table.number}")),
    );
  }
}
