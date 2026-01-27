import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop_ui/core/models/product.dart';
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';
import 'package:pos_desktop_ui/core/providers/product_provider.dart';
import 'package:pos_desktop_ui/features/auth/presentation/providers/auth_provider.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/open_drawer.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/product_screen.dart';
import 'package:pos_desktop_ui/features/reports/presentation/screens/reports_screen.dart';
import 'package:pos_desktop_ui/features/settings/presentation/screens/setting_screen.dart';
import 'package:pos_desktop_ui/features/stock/presentation/screens/stock_screen.dart';
import 'package:pos_desktop_ui/widgets/cart_panel.dart'; // Ensure this matches your cart file path

class POSLayout extends ConsumerStatefulWidget {
  const POSLayout({super.key});

  @override
  ConsumerState<POSLayout> createState() => _POSLayoutState();
}

class _POSLayoutState extends ConsumerState<POSLayout> {
  final Color sidebarTeal = Colors.orange;
  final Color accentYellow = const Color(0xFFFFCC4D);
  final Color workspaceBg = const Color(0xFFF4F7F9);

  int _currentIndex = 0;
  Product? selectedProduct;
  bool isCartVisible = true;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    Widget activeContent = _buildActiveContent(products);

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
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildHeader(),
                          Expanded(child: activeContent),
                        ],
                      ),
                    ),
                    if (isCartVisible) ...[
                      const VerticalDivider(width: 1, thickness: 1, color: Colors.black12),
                      const Expanded(flex: 1, child: CartPanel()),
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

  Widget _buildActiveContent(List<Product> products) {
    if (selectedProduct != null) {
      return Center(
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
      );
    }

    switch (_currentIndex) {
      case 0:
        return ProductScreen(
          products: products,
          onProductSelected: (p) => ref.read(cartProvider.notifier).addProduct(p),
          onActionSelected: (index) => setState(() => _currentIndex = index),
        );
      case 2: return const OpenDrawer();
      case 3: return ReportsScreen();
      case 5: return StockScreen();
      case 6: return const SettingScreen();
      default: return Center(child: Text("Module $_currentIndex Coming Soon"));
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
            icon: Icon(isCartVisible ? Icons.visibility_off_outlined : Icons.shopping_cart_outlined),
            onPressed: () => setState(() => isCartVisible = !isCartVisible),
          ),
        ],
      ),
    );
  }

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
          _sidebarItem(5, Icons.inventory_2, "Stock"),
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
        if (isLogout) {
          ref.read(authProvider.notifier).state = false;
        } else {
          setState(() { _currentIndex = index; selectedProduct = null; });
        }
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
}