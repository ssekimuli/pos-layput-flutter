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
import 'package:pos_desktop_ui/features/pos/presentation/screens/open_drawer.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/product_screen.dart';
import 'package:pos_desktop_ui/features/report/presentation/screens/report_screen.dart';
import 'package:pos_desktop_ui/features/sale/presentation/screens/sale_screen.dart';
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
                          _buildFooter(), // footer placed correctly
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
      case 0:
        return ProductScreen(
          products: products,
          onProductSelected: (p) =>
              ref.read(cartProvider.notifier).addProduct(p),
          onActionSelected: (index) => setState(() => _currentIndex = index),
        );
      case 1:
        return const SaleScreen();
      case 2:
        return const StockScreen();
      case 3:
        return const StoreScreen();
      case 4:
        return const SuppliersScreen();
      case 5:
        return const ReportScreen();
      case 6:
        return const SettingScreen();
      case 7:
        return const OpenDrawer();
      case 8:
        return const ExpenseScreen();
      case 9:
        return const CustomersScreen();
      case 10:
        return const HrmScreen();
      case 11:
        return const AccountingScreen();
      case 12:
        return const DepartmentScreen();
      default:
        return Center(child: Text("Module $_currentIndex Coming Soon"));
    }
  }

  /// Header
  Widget _buildHeader() {
    final cartItems = ref.watch(cartProvider);
    final totalItems =
        cartItems.fold(0, (sum, item) => sum + (item.quantity ?? 1));

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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }

  /// Footer
  Widget _buildFooter() {
    final actions = [
      "Open",
      "Close",
      "Re-print",
      "Hold",
      "Unhold",
      "New",
      "Change Rate",
      "Change Qty"
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(actions.length, (index) {
          return _buildFooterButton(actions[index],
              index: index, isActive: _activeFooterIndex == index);
        }),
      ),
    );
  }

  Widget _buildFooterButton(String label,
      {required int index, bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: SizedBox(
        height: 36,
        child: OutlinedButton(
          onPressed: () => setState(() => _activeFooterIndex = index),
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

  /// Sidebar
  Widget _buildSidebar() {
    return Container(
      width: 100,
      color: Colors.black, // sidebar background
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Icon(Icons.blur_on, color: Colors.white, size: 40),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  _sidebarItem(0, Icons.payment, "POS"),
                  _sidebarItem(1, Icons.point_of_sale, "Sale"),
                  _sidebarItem(2, Icons.inventory_2, "Stock"),
                  _sidebarItem(3, Icons.store, "Store"),
                  _sidebarItem(4, Icons.group, "Suppliers"),
                  _sidebarItem(5, Icons.bar_chart, "Report"),
                  _sidebarItem(7, Icons.receipt, "Drawer"),
                  _sidebarItem(8, Icons.money_off, "Expense"),
                  _sidebarItem(9, Icons.people, "Customers"),
                  _sidebarItem(10, Icons.badge, "HRM"),
                  _sidebarItem(11, Icons.account_balance, "Accounting"),
                  _sidebarItem(12, Icons.apartment, "Department"),
                  _sidebarItem(6, Icons.settings, "Settings"),
                ],
              ),
            ),
          ),
          _sidebarItem(13, Icons.logout, "Logout", isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label,
      {bool isLogout = false}) {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.zero, // rectangle buttons
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.white70, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
