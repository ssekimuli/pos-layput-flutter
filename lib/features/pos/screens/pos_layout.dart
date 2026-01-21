import 'package:flutter/material.dart';
import 'package:pos_desktop_ui/core/models/product.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/open_drawer.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/product_screen.dart';
import 'package:pos_desktop_ui/features/reports/presentation/screens/reports_screen.dart';
import 'package:pos_desktop_ui/features/settings/presentation/screens/setting_screen.dart';
import 'package:pos_desktop_ui/features/stock/presentation/screens/stock_screen.dart';

class POSLayout extends StatefulWidget {
  final VoidCallback onLogout;
  const POSLayout({super.key, required this.onLogout});

  @override
  State<POSLayout> createState() => _POSLayoutState();
}

class _POSLayoutState extends State<POSLayout> {
  // Brand Colors
  final Color brandTeal = const Color(0xFF006070); // Updated to match your theme
  final Color sidebarTeal = Colors.orange; // Keeping your original orange sidebar
  final Color accentYellow = const Color(0xFFFFCC4D);
  final Color workspaceBg = const Color(0xFFF4F7F9);

  int _currentIndex = 0;
  Product? selectedProduct;
  List<Product> cart = [];
  bool isCartVisible = true;

  // Mock Data
  final List<Product> products = List.generate(
      12,
      (i) => Product(
          name: i % 2 == 0 ? "Coffee Mug - 350ml" : "Espresso Cup",
          price: i % 2 == 0 ? 14.99 : 9.50,
          color: Colors.blueGrey));

  @override
  Widget build(BuildContext context) {
    Widget activeContent;

    if (selectedProduct != null) {
      activeContent = _contentWithHeader(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Detail for ${selectedProduct!.name}", style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => selectedProduct = null),
                child: const Text("Back to Gallery"),
              )
            ],
          ),
        ),
      );
    } else {
      switch (_currentIndex) {
        case 0:
          activeContent = _contentWithHeader(
            ProductScreen(
              products: products,
              // SINGLE TAP: View details
              onProductSelected: (p) => setState(() {
                cart.add(p); // This handles the double-tap logic from the screen
              }),
              onActionSelected: (index) => setState(() {
                _currentIndex = index;
              }),
            ),
          );
          break;
        case 2:
          activeContent = _contentWithHeader(const OpenDrawer());
          break;
        case 3:
          activeContent = _contentWithHeader(ReportsScreen());
          break;
        case 5:
          activeContent = _contentWithHeader(StockScreen());
          break;
        case 6:
          activeContent = _contentWithHeader(const SettingScreen());
          break;
        case 4:
          activeContent = _contentWithHeader(StockScreen());
          break;
        default:
          activeContent = _contentWithHeader(Center(child: Text("Module $_currentIndex Coming Soon")));
      }
    }

    return Scaffold(
      backgroundColor: sidebarTeal,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              decoration: BoxDecoration(
                color: workspaceBg, 
                borderRadius: BorderRadius.circular(28)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: activeContent),
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

  // --- Header Implementation ---
  Widget _contentWithHeader(Widget child) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.black12, 
            child: Icon(Icons.person, color: Colors.black)
          ),
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
            icon: Icon(isCartVisible ? Icons.visibility_off_outlined : Icons.shopping_cart_outlined),
            onPressed: () => setState(() => isCartVisible = !isCartVisible),
          ),
        ],
      ),
    );
  }

  // --- Sidebar Implementation ---
  Widget _buildSidebar() {
    return Container(
      width: 100,
      color: sidebarTeal,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Icon(Icons.blur_on, color: Colors.white, size: 40),
          ),
          _sidebarItem(0, Icons.payment, "Payment"),
          _sidebarItem(2, Icons.receipt, "Receipt"),
          _sidebarItem(3, Icons.bar_chart, "Reports"),
          _sidebarItem(4, Icons.inventory_2, "Stock"),
          _sidebarItem(5, Icons.inventory_2, "Inventory"),
          const Spacer(),
          _sidebarItem(6, Icons.settings, "Settings"),
          _sidebarItem(7, Icons.logout, "Logout", isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label, {bool isLogout = false}) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (isLogout) widget.onLogout();
        else setState(() { _currentIndex = index; selectedProduct = null; });
      },
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? accentYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.white70, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }

  // --- Right Order Panel (Cart) Implementation ---
  Widget _buildRightOrderPanel() {
    double subtotal = cart.fold(0, (sum, item) => sum + item.price);
    double tax = subtotal * 0.15;
    double discount = cart.isEmpty ? 0 : 5.00;
    double total = subtotal + tax - discount;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("+ Add Customer", style: TextStyle(fontSize: 12, color: Colors.black87)),
                ),
              ),
              const SizedBox(width: 8),
              _squareActionBtn(Icons.refresh),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Order Detail", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Items", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _textLink("Discount"),
                  _textLink("Coupon"),
                  _textLink("Note", last: true),
                ],
              )
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: cart.isEmpty 
              ? const Center(child: Text("Cart is empty", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, i) => _buildCartItem(cart[i], i),
                ),
          ),
          _buildSummary(subtotal, tax, discount, total),
        ],
      ),
    );
  }

  Widget _buildCartItem(Product item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(color: const Color(0xFFE9E2D5), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.coffee_outlined, size: 18, color: Colors.black26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const Text("SKU-0012", style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Text("\$${item.price.toStringAsFixed(2)}", 
            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF006070), fontSize: 13)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.redAccent),
            onPressed: () => setState(() => cart.removeAt(index)),
          )
        ],
      ),
    );
  }

  Widget _buildSummary(double sub, double tax, double disc, double total) {
    return Column(
      children: [
        const Divider(),
        _summaryRow("Subtotal", sub),
        _summaryRow("Tax", tax),
        _summaryRow("Discount", -disc),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total Payable", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _actionBtn("Checkout", accentYellow, Colors.black, Icons.shopping_cart_checkout)),
            const SizedBox(width: 8),
            Expanded(child: _actionBtn("Fast Cash", brandTeal, Colors.white, Icons.bolt)),
          ],
        )
      ],
    );
  }

  // --- Small UI Helpers ---
  Widget _summaryRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text("\$${val.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg, foregroundColor: fg,
        minimumSize: const Size(0, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _squareActionBtn(IconData icon) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
      child: IconButton(onPressed: () {}, icon: Icon(icon, size: 18), color: Colors.black54),
    );
  }

  Widget _textLink(String text, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(right: last ? 0 : 8),
      child: Text(text, style: TextStyle(color: brandTeal, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}