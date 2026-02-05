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
import 'package:pos_desktop_ui/widgets/cart_panel.dart';

class POSLayout extends ConsumerStatefulWidget {
  const POSLayout({super.key});

  @override
  ConsumerState<POSLayout> createState() => _POSLayoutState();
}

class _POSLayoutState extends ConsumerState<POSLayout> {
  // Theme Colors
  final Color sidebarTeal = Colors.orange;
  final Color accentYellow = const Color(0xFFFFCC4D);
  final Color workspaceBg = const Color(0xFFF4F7F9);
  
  // UI State
  int _currentIndex = 0;
  int _activeFooterIndex = 0; // Tracks which footer button is orange
  Product? selectedProduct;
  bool isCartVisible = false;

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
                    // Main Content Area
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildHeader(),
                          Expanded(child: activeContent),
                          _buildFooter(), 
                        ],
                      ),
                    ),
                    // Right Cart Panel
                    if (isCartVisible) ...[
                      const VerticalDivider(
                        width: 1, 
                        thickness: 1, 
                        color: Colors.black12
                      ),
                      const Expanded(
                        flex: 1, 
                        child: CartPanel()
                      ),
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

  /// Main View Switcher
  Widget _buildActiveContent(List<Product> products) {
    if (selectedProduct != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Detail for ${selectedProduct!.name}", 
                style: const TextStyle(fontSize: 20)),
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

  /// Top Navigation Bar
  Widget _buildHeader() {
    final cartItems = ref.watch(cartProvider);
    final totalItems = cartItems.fold(0, (sum, item) => sum + (item.quantity ?? 1));

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
              
              Text("Welcome Asad!", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Store Admin", 
                  style: TextStyle(fontSize: 12, color: Colors.black45)),
            ],
          ),
          const Spacer(),
          Stack(
  alignment: Alignment.topRight,
  children: [
    // The main button that toggles the state
    IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isCartVisible ? Icons.visibility_off_outlined : Icons.shopping_cart_outlined,
          key: ValueKey<bool>(isCartVisible), // Required for AnimatedSwitcher to work
        ),
      ),
      onPressed: () => setState(() => isCartVisible = !isCartVisible),
    ),

    // The Badge - only show if items exist AND cart isn't "hidden"
    if (totalItems > 0 && !isCartVisible)
      Positioned(
        right: 4, // Adjusted for better alignment
        top: 4,
        child: IgnorePointer( // Prevents the badge from blocking the button click
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle, // Cleaner than manual border radius
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              '$totalItems',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
  ],
)
        ],
      ),
    );
  }

  /// Footer Section (Reduced Height + Orange/Black Theme)
  Widget _buildFooter() {
    final List<String> actions = [
      "Open", "Close", "Re-print", "Hold", "Unhold", "New", "Change Rate", "Change Qty"
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12), // Compact Padding
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(actions.length, (index) {
                return _buildFooterButton(
                  actions[index], 
                  index: index,
                  isActive: _activeFooterIndex == index,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String label, {required int index, bool isActive = false}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: SizedBox(
      height: 36, 
      child: OutlinedButton(
        onPressed: () => setState(() => _activeFooterIndex = index),
        style: OutlinedButton.styleFrom(
          // Active: Orange | Inactive: Black
          backgroundColor: isActive ? Colors.orange : Colors.black,
          
          // Border matches the background for a clean solid look
          side: BorderSide(
            color: isActive ? Colors.orange : Colors.black, 
            width: 1
          ),
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          label,
          style: TextStyle(
            // Both states use white text for contrast against dark backgrounds
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}

  /// Sidebar Navigation
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
          setState(() { 
            _currentIndex = index; 
            selectedProduct = null; 
          });
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