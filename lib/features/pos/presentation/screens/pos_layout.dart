import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop_ui/core/models/product.dart';
import 'package:pos_desktop_ui/core/providers/cart_provider.dart';
import 'package:pos_desktop_ui/core/providers/product_provider.dart';
import 'package:pos_desktop_ui/features/accounting/presentation/screens/accounting_screen.dart';
import 'package:pos_desktop_ui/features/auth/presentation/providers/auth_provider.dart';
import 'package:pos_desktop_ui/features/customers/presentation/screens/customers_screen.dart';
import 'package:pos_desktop_ui/features/department/presentation/screens/department_screen.dart';
import 'package:pos_desktop_ui/features/expense/presentation/screens/expense_screen.dart';
import 'package:pos_desktop_ui/features/hrm/presentation/screens/hrm_screen.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/hotel_screen.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/open_drawer.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/product_screen.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/restaurant_screen.dart';
import 'package:pos_desktop_ui/features/report/presentation/screens/report_screen.dart';
import 'package:pos_desktop_ui/features/dashboard/dashboard_screen.dart';
import 'package:pos_desktop_ui/features/settings/presentation/screens/setting_screen.dart';
import 'package:pos_desktop_ui/features/stock/presentation/screens/stock_screen.dart';
import 'package:pos_desktop_ui/features/store/presentation/screens/store_screen.dart';
import 'package:pos_desktop_ui/features/suppliers/presentation/screens/suppliers_screen.dart';
import 'package:pos_desktop_ui/widgets/cart_panel.dart';

class POSLayout extends ConsumerStatefulWidget {
  const POSLayout({super.key});

  @override
  ConsumerState<POSLayout> createState() => _POSLayoutState();
}

class _POSLayoutState extends ConsumerState<POSLayout> {
  /// Theme Colors
  final Color accentYellow = const Color(0xFFFFCC4D);
  final Color workspaceBg = const Color(0xFFF4F7F9);

  /// UI State
  int _currentIndex = 0;
  int _activeFooterIndex = 0;
  Product? selectedProduct;
  bool isCartVisible = false;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    Widget activeContent = _buildActiveContent(products);

    return Scaffold(
      backgroundColor: Colors.orange,
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
                          _buildFooter(), // Original footer kept as requested
                        ],
                      ),
                    ),
                    if (isCartVisible) ...[
                      const VerticalDivider(
                          width: 1, thickness: 1, color: Colors.black12),
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

  /// Active Content
  Widget _buildActiveContent(List<Product> products) {
    switch (_currentIndex) {
      case 13:
        return DashboardScreen(
          onNavigate: (index) => setState(() => _currentIndex = index),
        );
      case 0: return ProductScreen(
          products: products,
          onProductSelected: (p) =>
              ref.read(cartProvider.notifier).addProduct(p),
          onActionSelected: (index) => setState(() => _currentIndex = index),
        );
      case 2: return const StockScreen();
      case 3: return const StoreScreen();
      case 4: return const SuppliersScreen();
      case 5: return const ReportScreen();
      case 6: return const SettingScreen();
      case 7: return const OpenDrawer();
      case 8: return const ExpenseScreen();
      case 9: return const CustomersScreen();
      case 10: return const HrmScreen();
      case 11: return const AccountingScreen();
      case 12: return const DepartmentScreen();
      case 14: return const RestaurantScreen();
      case 15: return const HotelScreen();
      default:
        return Center(child: Text("Module $_currentIndex Coming Soon"));
    }
  }

  /// Header
  Widget _buildHeader() {
    final cartItems = ref.watch(cartProvider);
    final totalItems = cartItems.items.fold(0, (sum, item) => sum + (item.quantity ?? 1));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          const CircleAvatar(
              backgroundColor: Colors.black12, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          const Text("Welcome Admin",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: Icon(isCartVisible
                    ? Icons.visibility_off
                    : Icons.shopping_cart),
                onPressed: () => setState(() => isCartVisible = !isCartVisible),
              ),
              if (totalItems > 0 && !isCartVisible)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text('$totalItems',
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }

  /// Original Footer (Unchanged)
Widget _buildFooter() {
    final List<String> actions = [
      "Open", "Close", "Re-print", "Hold", "Unhold", "New", "Change Rate", "Change Qty"
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
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
          onPressed: () {
            setState(() => _activeFooterIndex = index);
            _showActionModal(context, label); // Logic to trigger the modal
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isActive ? Colors.orange : Colors.black,
            side: BorderSide(
                color: isActive ? Colors.orange : Colors.black, width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 12),
          ),
        ),
      ),
    );
  }

  /// Helper to show the Modal based on the label
  void _showActionModal(BuildContext context, String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Action: $label"),
          content: SizedBox(
            width: 400,
            child: Text("Are you sure you want to perform the '$label' action?"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Add specific logic for each action here
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
  /// Sidebar with Individual Dividers
  Widget _buildSidebar() {
    final List<Map<String, dynamic>> menuItems = [
      {'index': 13, 'icon': Icons.dashboard, 'label': "Dashboard"},
      {'index': 0, 'icon': Icons.payment, 'label': "POS"},
      {'index': 1, 'icon': Icons.point_of_sale, 'label': "Sale"},
      {'index': 14, 'icon': Icons.restaurant, 'label': "Restaurant"},
      {'index': 15, 'icon': Icons.hotel, 'label': "Hotel"},
      {'index': 2, 'icon': Icons.inventory_2, 'label': "Stock"},
      {'index': 3, 'icon': Icons.store, 'label': "Store"},
      {'index': 4, 'icon': Icons.group, 'label': "Suppliers"},
      {'index': 9, 'icon': Icons.people, 'label': "Customers"},
      {'index': 5, 'icon': Icons.bar_chart, 'label': "Report"},
      {'index': 7, 'icon': Icons.receipt, 'label': "Drawer"},
      {'index': 8, 'icon': Icons.money_off, 'label': "Expense"},
      {'index': 10, 'icon': Icons.badge, 'label': "HRM"},
      {'index': 11, 'icon': Icons.account_balance, 'label': "Accounting"},
      {'index': 12, 'icon': Icons.apartment, 'label': "Department"},
      {'index': 6, 'icon': Icons.settings, 'label': "Settings"},
    ];

    return Container(
      width: 100,
      color: Colors.black,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Icon(Icons.blur_on, color: Colors.white, size: 40),
          ),
          _buildDivider(),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: menuItems.length,
                separatorBuilder: (context, index) => _buildDivider(),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return _sidebarItem(item['index'], item['icon'], item['label']);
                },
              ),
            ),
          ),
          _buildDivider(),
          _sidebarItem(13, Icons.logout, "Logout", isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
      height: 1,
    );
  }

  /// Sidebar Item with Red Logout Color
  Widget _sidebarItem(int index, IconData icon, String label, {bool isLogout = false}) {
    bool isSelected = _currentIndex == index;
    bool isHovered = _hoveredIndex == index;

    final Color activeColor = isLogout ? Colors.redAccent : Colors.orange;
    final Color hoverColor = isLogout 
        ? Colors.red.withOpacity(0.2) 
        : Colors.white.withOpacity(0.1);
    
    Color contentColor;
    if (isSelected) {
      contentColor = Colors.black;
    } else if (isHovered) {
      contentColor = Colors.white;
    } else {
      contentColor = isLogout ? Colors.redAccent.withOpacity(0.8) : Colors.white70;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? activeColor 
                : (isHovered ? hoverColor : Colors.transparent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: contentColor, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 11,
                  fontWeight: isSelected || isHovered || isLogout ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}