import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../widgets/cart_panel.dart';

class POSLayout extends StatefulWidget {
  const POSLayout({super.key});

  @override
  State<POSLayout> createState() => _POSLayoutState();
}

class _POSLayoutState extends State<POSLayout> {
  // 1. ADD THIS TRACKER
  int _currentIndex = 0; 
  
  bool isCartVisible = true;
  Product? selectedProduct;
  List<Product> cart = [];

  final List<Product> products = List.generate(
    7,
    (i) => Product(
      name: "Item ${i + 1}",
      price: (i + 1) * 12.50,
      color: Colors.blueAccent.withOpacity(0.1 * (i % 5 + 2)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Navigation Sidebar
          NavigationRail(
            // UPDATE: Use the tracker variable
            selectedIndex: _currentIndex, 
            // UPDATE: Add this function to make buttons clickable
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
                selectedProduct = null; // Go back to grid when switching tabs
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.store), label: Text('POS')),
              NavigationRailDestination(icon: Icon(Icons.receipt), label: Text('Orders')),
            ],
          ),
          const VerticalDivider(width: 1),

          // 2. Dynamic Middle Section
          Expanded(
            flex: 3,
            child: _buildMainContent(), // Logic moved here to handle switching
          ),

          // 3. Conditional Cart
          // UPDATE: Only show cart if on the POS tab (index 0)
          if (isCartVisible && _currentIndex == 0)
            CartPanel(
              cart: cart, 
              onToggle: () => setState(() => isCartVisible = false),
              onRemove: (index) => setState(() => cart.removeAt(index)),
            ),
        ],
      ),
    );
  }

  // --- NEW: Logic to switch between POS and Orders ---
  Widget _buildMainContent() {
    if (_currentIndex == 1) {
      return const Center(
        child: Text("Orders History Screen", style: TextStyle(fontSize: 24)),
      );
    }

    // This is your original POS logic
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: selectedProduct == null 
                ? _buildGrid() 
                : _buildDetail(selectedProduct!),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text("POS System", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (!isCartVisible)
            IconButton.filledTonal(
              onPressed: () => setState(() => isCartVisible = true),
              icon: const Icon(Icons.shopping_cart),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, mainAxisSpacing: 15, crossAxisSpacing: 15),
      itemCount: products.length,
      itemBuilder: (context, i) => Card(
        child: InkWell(
          onTap: () => setState(() => selectedProduct = products[i]),
          child: Center(child: Text(products[i].name)),
        ),
      ),
    );
  }

  Widget _buildDetail(Product p) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(p.name, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {
              cart.add(p);
              isCartVisible = true;
            }),
            child: const Text("Add to Cart"),
          ),
          TextButton(
              onPressed: () => setState(() => selectedProduct = null),
              child: const Text("Back"))
        ],
      ),
    );
  }
}