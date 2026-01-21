import 'package:flutter/material.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Stock Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  title: Text("Inventory Item #$i"),
                  subtitle: const Text("Stock: 100+"),
                  trailing: const Icon(Icons.edit, size: 20),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}