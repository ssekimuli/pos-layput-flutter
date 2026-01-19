import 'package:flutter/material.dart';
import 'package:pos_desktop_ui/models/product.dart';
import 'purchase_screen.dart';
import 'reports_screen.dart';
import 'stock_screen.dart';

class POSLayout extends StatefulWidget {
  final VoidCallback onLogout;
  const POSLayout({super.key, required this.onLogout});

  @override
  State<POSLayout> createState() => _POSLayoutState();
}

class _POSLayoutState extends State<POSLayout> {
  final Color brandTeal = Colors.orange;
  final Color accentYellow = const Color(0xFFFFD54F);
  final Color workspaceBg = const Color(0xFFF3F6F9);

  int _currentIndex = 0;
  Product? selectedProduct;
  List<Product> cart = [];
  bool isCartVisible = true;

  final List<Product> products = List.generate(
      8,
      (i) => Product(
          name: i % 2 == 0 ? "Coffee Mug - 350ml" : "Espresso Cup",
          price: i % 2 == 0 ? 14.99 : 9.50,
          color: Colors.blueGrey));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandTeal,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              decoration: BoxDecoration(color: workspaceBg, borderRadius: BorderRadius.circular(28)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _buildMainContent()),
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
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Icon(Icons.blur_on, color: Colors.white, size: 40),
                    ),
                    _sidebarItem(0, Icons.payment, "Payment"),
                    _sidebarItem(1, Icons.shopping_cart, "Purchase"),
                    _sidebarItem(2, Icons.receipt, "Receipt"),
                    _sidebarItem(3, Icons.bar_chart, "Reports"),
                    _sidebarItem(4, Icons.description, "Invoices"),
                    _sidebarItem(5, Icons.inventory_2, "Stock"),
                    const Spacer(),
                    const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                    _sidebarItem(6, Icons.settings, "Settings"),
                    _sidebarItem(7, Icons.logout, "Logout", isLogout: true),
                    const SizedBox(height: 20),
                  ],
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
        if (isLogout) {
          widget.onLogout();
        } else {
          setState(() {
            _currentIndex = index;
            selectedProduct = null;
          });
        }
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
            Icon(icon, color: isSelected ? Colors.black : Colors.white70),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (selectedProduct != null) {
      return PurchaseScreen(
        product: selectedProduct!,
        onBack: () => setState(() => selectedProduct = null),
        onAddToCart: (p) {
          setState(() {
            cart.add(p);
            selectedProduct = null;
            isCartVisible = true;
          });
        },
      );
    }

    switch (_currentIndex) {
      case 0: return _buildProductGallery();
      case 3: return const ReportsScreen();
      case 5: return const StockScreen();
      default:
        return _buildPlaceholderScreen(["Payment", "Purchase", "Receipt", "Reports", "Invoices", "Stock", "Settings"][_currentIndex]);
    }
  }

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
                        crossAxisCount: 4, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8),
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

  Widget _productCard(Product p) {
    return InkWell(
      onTap: () => setState(() => selectedProduct = p),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee, size: 60, color: p.color),
            const SizedBox(height: 8),
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("\$${p.price}", style: TextStyle(color: brandTeal, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.black12, child: Icon(Icons.person, color: Colors.black)),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome Asad!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Store Admin", style: TextStyle(fontSize: 12, color: Colors.black45)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(isCartVisible ? Icons.visibility_off : Icons.shopping_cart, color: Colors.black),
            onPressed: () => setState(() => isCartVisible = !isCartVisible),
          ),
        ],
      ),
    );
  }

  Widget _buildBlackQuickActions() {
    final actions = ["Open", "Close", "Hold", "New"];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: actions
            .map((a) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                    onPressed: () {},
                    child: Text(a),
                  ),
                ))
            .toList(),
      ),
    );
  }

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
                ? const Center(child: Text("Cart is empty"))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, i) => ListTile(
                      title: Text(cart[i].name, style: const TextStyle(fontSize: 13)),
                      trailing: Text("\$${cart[i].price}"),
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
                const Text("Total", style: TextStyle(color: Colors.white)),
                Text("\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentYellow, minimumSize: const Size(double.infinity, 50)),
            onPressed: () {},
            child: const Text("Checkout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderScreen(String title) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: Center(child: Text("$title Module coming soon", style: const TextStyle(fontSize: 20, color: Colors.grey)))),
      ],
    );
  }
}