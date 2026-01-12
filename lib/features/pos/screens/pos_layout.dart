import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../widgets/cart_panel.dart';

class POSLayout extends StatefulWidget {
  // 1. ADDED: The logout callback parameter
  final VoidCallback onLogout;

  // 2. UPDATED: The constructor to require onLogout
  const POSLayout({super.key, required this.onLogout});

  @override
  State<POSLayout> createState() => _POSLayoutState();
}

class _POSLayoutState extends State<POSLayout> {
  int _currentIndex = 0; 
  bool isCartVisible = true;
  Product? selectedProduct;
  List<Product> cart = [];

  final List<Product> products = List.generate(7, (i) => Product(
      name: "Item ${i + 1}", 
      price: (i + 1) * 12.5, 
      color: Colors.orange.withOpacity(0.2)
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar with Shadow
          Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: NavigationRail(
              selectedIndex: _currentIndex > 3 ? null : _currentIndex,
              backgroundColor: Colors.white,
              onDestinationSelected: (idx) => setState(() {
                _currentIndex = idx;
                selectedProduct = null;
              }),
              labelType: NavigationRailLabelType.all,
              trailing: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings, color: _currentIndex == 4 ? Colors.orange : Colors.grey),
                      onPressed: () => setState(() => _currentIndex = 4),
                    ),
                    // 3. UPDATED: The logout button now triggers the callback
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () {
                        // This calls the function passed from main.dart
                        widget.onLogout(); 
                      },
                      tooltip: 'Logout',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.store), label: Text('POS')),
                NavigationRailDestination(icon: Icon(Icons.receipt), label: Text('Orders')),
                NavigationRailDestination(icon: Icon(Icons.inventory), label: Text('Stock')),
                NavigationRailDestination(icon: Icon(Icons.analytics), label: Text('Stats')),
              ],
            ),
          ),

          // 2. Middle Content
          Expanded(flex: 3, child: _buildMainContent()),

          // 3. Conditional Cart
          if (isCartVisible && _currentIndex == 0)
            CartPanel(
              cart: cart,
              onToggle: () => setState(() => isCartVisible = false),
              onRemove: (idx) => setState(() => cart.removeAt(idx)),
            ),
        ],
      ),
    );
  }

  // ... rest of the helper methods (_buildMainContent, _buildHeader, etc.) remain unchanged ...
  Widget _buildMainContent() {
    switch (_currentIndex) {
      case 1: return const Center(child: Text("Orders History", style: TextStyle(fontSize: 24)));
      case 2: return const Center(child: Text("Inventory", style: TextStyle(fontSize: 24)));
      case 3: return const Center(child: Text("Statistics", style: TextStyle(fontSize: 24)));
      case 4: return const Center(child: Text("Settings", style: TextStyle(fontSize: 24)));
      default:
        return Column(
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selectedProduct == null ? _buildGrid() : _buildDetail(selectedProduct!),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text("POS System", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (!isCartVisible)
            IconButton.filled(onPressed: () => setState(() => isCartVisible = true), icon: const Icon(Icons.shopping_cart)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, mainAxisSpacing: 15, crossAxisSpacing: 15),
      itemCount: products.length,
      itemBuilder: (context, i) => Card(
        elevation: 2,
        child: InkWell(
          onTap: () => setState(() => selectedProduct = products[i]),
          child: Center(child: Text(products[i].name)),
        ),
      ),
    );
  }

  Widget _buildDetail(Product p) {
    return Center(
      child: Card(
        child: Container(
          width: 350, padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.name, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() { cart.add(p); isCartVisible = true; }),
                child: const Text("Add to Cart"),
              ),
              TextButton(onPressed: () => setState(() => selectedProduct = null), child: const Text("Back"))
            ],
          ),
        ),
      ),
    );
  }
}