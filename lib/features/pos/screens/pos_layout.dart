import 'package:flutter/material.dart';
import 'package:pos_desktop_ui/features/pos/screens/open_drawer.dart';
import 'package:pos_desktop_ui/features/pos/screens/product_screen.dart';
import 'package:pos_desktop_ui/features/pos/screens/purchase_screen.dart';
import 'package:pos_desktop_ui/features/pos/screens/reports_screen.dart';
import 'package:pos_desktop_ui/features/pos/screens/setting_screen.dart';
import 'package:pos_desktop_ui/features/pos/screens/stock_screen.dart';
import 'package:pos_desktop_ui/models/product.dart';

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
              onProductSelected: (p) => setState(() => selectedProduct = p),
              onActionSelected: (index) => setState(() {
                _currentIndex = index;
              }),
            ),
          );
          break;
        case 1:
          activeContent = _contentWithHeader(PurchaseScreen(
            product: products[0],
            onBack: () => setState(() => selectedProduct = null),
            onAddToCart: (p) => setState(() {
              cart.add(p);
              isCartVisible = true;
            }),
          ));
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
        default:
          activeContent = _contentWithHeader(Center(child: Text("Module $_currentIndex Coming Soon")));
      }
    }

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

  // --- Sidebar & Helper Widgets ---

  Widget _buildSidebar() {
    return Container(
      width: 100,
      color: brandTeal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Allows the sidebar to scroll when items overflow
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
                    // The Spacer ensures settings/logout stay at the bottom 
                    // unless the screen is too short, then it scrolls.
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

 Widget _buildRightOrderPanel() {
  double subtotal = cart.fold(0, (sum, item) => sum + item.price);
  double tax = subtotal * 0.20; 
  double discount = 12.00; 
  double payableAmount = subtotal + tax - discount;

  return Container(
    color: const Color(0xFFF8FAFB),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced padding
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Compact Header Actions ---
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 14), // Smaller icon
                label: const Text("Add Customer", style: TextStyle(fontSize: 12)), // Smaller font
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12), // Shorter button
                ),
              ),
            ),
            const SizedBox(width: 6),
            _iconActionBtn(Icons.add),
            const SizedBox(width: 6),
            _iconActionBtn(Icons.refresh),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Order Detail", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Smaller header
        const SizedBox(height: 12),
        
        // --- Add/Discount/Coupon Header ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Add", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Row(
              children: [
                _textActionBtn("Discount"),
                _textActionBtn("Coupon"),
                _textActionBtn("Note", last: true),
              ],
            )
          ],
        ),
        const Divider(height: 20),

        // --- Cart Items List ---
        Expanded(
          child: cart.isEmpty
              ? const Center(child: Text("Cart is empty", style: TextStyle(fontSize: 12)))
              : ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, i) => _buildCartItemCard(cart[i]),
                ),
        ),

        // --- Compact Summary Section ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _priceRow("Subtotal", subtotal),
              _priceRow("Tax", tax),
              _priceRow("Discount", -discount, isDiscount: true),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text("\$${payableAmount.toStringAsFixed(2)}", 
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // --- Small Bottom Buttons ---
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC4D),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48), // Reduced height
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                label: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006070),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48), // Reduced height
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {},
                icon: const Icon(Icons.save, size: 18),
                label: const Text("Fast Cash", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildCartItemCard(Product item) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black.withOpacity(0.05)),
    ),
    child: Row(
      children: [
        Container(
          width: 50, // Smaller image
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.image, size: 20, color: Colors.grey[400]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Text("SKU-001", style: TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 4),
              Row(
                children: [
                  _qtyBtn(Icons.remove),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  _qtyBtn(Icons.add, isAdd: true),
                ],
              )
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("\$${item.price.toStringAsFixed(2)}", 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006070), fontSize: 13)),
          ],
        )
      ],
    ),
  );
}

// --- Helper UI Components with Smaller Scaling ---

Widget _qtyBtn(IconData icon, {bool isAdd = false}) {
  return Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: isAdd ? const Color(0xFF006070) : Colors.black.withOpacity(0.05),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 12, color: isAdd ? Colors.white : Colors.black54),
  );
}

Widget _priceRow(String label, double value, {bool isDiscount = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11)),
        Text(
          "${isDiscount ? '-' : ''}\$${value.abs().toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ],
    ),
  );
}

Widget _iconActionBtn(IconData icon) {
  return Container(
    width: 36, // Smaller fixed size
    height: 36,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {}, 
      icon: Icon(icon, size: 16)
    ),
  );
}

Widget _textActionBtn(String text, {bool last = false}) {
  return Padding(
    padding: EdgeInsets.only(right: last ? 0 : 8),
    child: Text(text, 
      style: const TextStyle(color: Color(0xFF006070), fontWeight: FontWeight.bold, fontSize: 11)),
  );
}
}