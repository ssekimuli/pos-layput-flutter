import 'package:flutter/material.dart';
import '../../../models/product.dart';

class POSLayout extends StatefulWidget {
  final VoidCallback onLogout;
  const POSLayout({super.key, required this.onLogout});

  @override
  State<POSLayout> createState() => _POSLayoutState();
}

class _POSLayoutState extends State<POSLayout> {
  // --- DESIGN SYSTEM COLORS ---
  final Color brandTeal =Colors.orange;// const Color(0xFF015D70); 
  final Color accentYellow = const Color(0xFFFFD54F); 
  final Color workspaceBg = const Color(0xFFF3F6F9); 
  
  int _currentIndex = 0;
  Product? selectedProduct;
  List<Product> cart = [];
  bool isCartVisible = true; // State for hiding/showing cart

  // YOUR PRODUCT LIST
  final List<Product> products = List.generate(8, (i) => Product(
      name: "Coffee Mug - 350ml", 
      price: 14.99, 
      color: Colors.orange.withOpacity(0.2)
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandTeal, 
      body: Row(
        children: [
          // 1. Sidebar (Fixed Overflow with SingleChildScrollView)
          _buildSidebar(),

          // 2. Main Workspace
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 16, 16), 
              decoration: BoxDecoration(
                color: workspaceBg,
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  children: [
                    // Main Content (Product Grid / Details)
                    Expanded(flex: 3, child: _buildMainContent()),
                    
                    // Conditional Cart Panel
                    if (isCartVisible) ...[
                      const VerticalDivider(width: 1, thickness: 1, color: Colors.black12),
                      Expanded(flex: 1, child: _buildRightOrderPanel()),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SIDEBAR (SCROLLABLE TO PREVENT OVERFLOW) ---
  Widget _buildSidebar() {
    return SizedBox(
      width: 100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.blur_on, color: Colors.white, size: 40),
                      const SizedBox(height: 30),
                      _sidebarItem(0, Icons.payment, "Payment"),
                      _sidebarItem(1, Icons.shopping_cart, "Purchase"),
                      _sidebarItem(2, Icons.receipt, "Receipt"),
                      _sidebarItem(3, Icons.bar_chart, "Reports"),
                      _sidebarItem(4, Icons.description, "Invoices"),
                      _sidebarItem(5, Icons.inventory_2, "Stock"),
                      const Spacer(), 
                      _sidebarItem(6, Icons.settings, "Settings"),
                      _sidebarItem(7, Icons.logout, "Logout", isLogout: true),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label, {bool isLogout = false}) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (isLogout) widget.onLogout();
        setState(() => _currentIndex = index);
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? accentYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? brandTeal : Colors.white70),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? brandTeal : Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // --- CONTENT LOGIC ---
  Widget _buildMainContent() {
    if (selectedProduct != null) return _buildProductDetail(selectedProduct!);

    switch (_currentIndex) {
      case 0: return _buildProductGallery();
      case 1: return _buildPlaceholder("Purchase");
      case 2: return _buildPlaceholder("Receipt");
      case 3: return _buildPlaceholder("Reports");
      case 4: return _buildPlaceholder("Invoices");
      case 5: return _buildPlaceholder("Stock");
      default: return _buildProductGallery();
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
          const SizedBox(width: 12),
          const Text("Welcome Asad!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          // Toggle Cart Button
          IconButton(
            icon: Icon(isCartVisible ? Icons.visibility_off : Icons.shopping_cart, color: brandTeal),
            onPressed: () => setState(() => isCartVisible = !isCartVisible),
          ),
          const SizedBox(width: 8),
          _topCircleBtn(Icons.notifications_none),
        ],
      ),
    );
  }

  // --- PRODUCT GALLERY ---
  Widget _buildProductGallery() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8
              ),
              itemCount: products.length,
              itemBuilder: (context, i) => _productCard(products[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _productCard(Product p) {
    return InkWell(
      onTap: () => setState(() => selectedProduct = p),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.coffee, size: 60, color: Colors.blueGrey),
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("\$${p.price}", style: TextStyle(color: brandTeal, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- PRODUCT DETAIL ---
  Widget _buildProductDetail(Product p) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() { cart.add(p); selectedProduct = null; isCartVisible = true; }),
            child: const Text("Add to Cart"),
          ),
          TextButton(onPressed: () => setState(() => selectedProduct = null), child: const Text("Back")),
        ],
      ),
    );
  }

  // --- RIGHT ORDER PANEL ---
  Widget _buildRightOrderPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Order Detail", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => isCartVisible = false)),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, i) => ListTile(title: Text(cart[i].name), trailing: Text("\$${cart[i].price}")),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentYellow, minimumSize: const Size(double.infinity, 50)),
            onPressed: () {}, 
            child: Text("Checkout", style: TextStyle(color: brandTeal)),
          ),
        ],
      ),
    );
  }

  Widget _topCircleBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.black54, size: 20),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: Center(child: Text("$title Screen", style: const TextStyle(fontSize: 24)))),
      ],
    );
  }
}