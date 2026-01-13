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
  final Color brandTeal = Colors.orange; 
  final Color accentYellow = const Color(0xFFFFD54F); 
  final Color workspaceBg = const Color(0xFFF3F6F9); 
  final Color darkCanvas = const Color(0xFF1A1C1E); // Black sidebar color
  
  int _currentIndex = 0;
  Product? selectedProduct;
  List<Product> cart = [];
  bool isCartVisible = true;

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
          // 1. Sidebar (Black Background)
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
                    // Main Content
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

  // --- SIDEBAR (FIXED OVERFLOW & BLACK THEME) ---
  Widget _buildSidebar() {
  return Container(
    width: 100,
    color: brandTeal,
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
                    
                    // --- Added Divider and Spacer ---
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Divider(color: Colors.white24, thickness: 1),
                    ),
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
        // --- Added Shadow Logic ---
        boxShadow: isSelected 
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] 
          : [], 
      ),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.black : Colors.white70),
          const SizedBox(height: 4),
          Text(label, 
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70, 
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
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
      default: return _buildPlaceholder("${_currentIndex}Module");
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome Asad!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Store Admin", style: TextStyle(fontSize: 12, color: Colors.black45)),
            ],
          ),
          const Spacer(),
          // Toggle Cart Button
          IconButton(
            icon: Icon(isCartVisible ? Icons.visibility_off : Icons.shopping_cart, color: Colors.black),
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
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, i) => _productCard(products[i]),
                  ),
                ),
                _buildBlackQuickActions(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlackQuickActions() {
    final actions = ["Open", "Close", "Hold", "New"];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: actions.map((a) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () {},
            child: Text(a),
          ),
        )).toList(),
      ),
    );
  }

  Widget _productCard(Product p) {
    return InkWell(
      onTap: () => setState(() => selectedProduct = p),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.coffee, size: 60, color: Colors.blueGrey),
            const SizedBox(height: 8),
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
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.coffee, size: 100, color: Colors.blueGrey),
            const SizedBox(height: 16),
            Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("\$${p.price}", style: TextStyle(fontSize: 20, color: brandTeal)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () => setState(() { cart.add(p); selectedProduct = null; isCartVisible = true; }),
              child: const Text("Add to Cart"),
            ),
            TextButton(onPressed: () => setState(() => selectedProduct = null), child: const Text("Back", style: TextStyle(color: Colors.black54)))
          ],
        ),
      ),
    );
  }

  // --- RIGHT ORDER PANEL (CART) ---
  Widget _buildRightOrderPanel() {
    double total = cart.fold(0, (sum, item) => sum + item.price);

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
          const Divider(),
          Expanded(
            child: cart.isEmpty 
              ? const Center(child: Text("Cart is empty", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, i) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(cart[i].name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    trailing: Text("\$${cart[i].price.toStringAsFixed(2)}"),
                  ),
                ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentYellow, 
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
            onPressed: () {}, 
            child: const Text("Checkout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _topCircleBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white, 
        shape: BoxShape.circle, // FIXED: Changed from BoxShadow to BoxShape
        border: Border.all(color: Colors.black12)
      ),
      child: Icon(icon, color: Colors.black87, size: 20),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: Center(child: Text("$title Screen", style: const TextStyle(fontSize: 24, color: Colors.grey)))),
      ],
    );
  }
}