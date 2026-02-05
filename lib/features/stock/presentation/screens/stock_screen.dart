import 'package:flutter/material.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  
  bool _isEditing = false;
  int? _editingIndex;

  // Mock Data Source
  final List<Map<String, dynamic>> _inventory = List.generate(15, (index) => {
    "name": "Product ${index + 1}",
    "sku": "SKU-882$index",
    "category": "Beverages",
    "stock": index + 5,
    "price": (index + 5.99).toStringAsFixed(2),
  });

  // Open Side Sheet for Add or Edit
  void _openProductForm({Map<String, dynamic>? product, int? index}) {
    setState(() {
      if (product != null) {
        _isEditing = true;
        _editingIndex = index;
        _nameController.text = product['name'];
        _skuController.text = product['sku'];
        _priceController.text = product['price'];
        _stockController.text = product['stock'].toString();
      } else {
        _isEditing = false;
        _editingIndex = null;
        _nameController.clear();
        _skuController.clear();
        _priceController.clear();
        _stockController.clear();
      }
    });
    _scaffoldKey.currentState!.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      // --- SIDE SHEET FORM ---
      endDrawer: Drawer(
        width: 400,
        child: _buildProductForm(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isCompact = constraints.maxWidth < 900;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSummaryCards(),
                const SizedBox(height: 20),
                _buildActionBar(),
                const SizedBox(height: 12),
                Expanded(child: _buildTableContainer()),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.inventory_2_rounded, color: Color(0xFF006070), size: 28),
        const SizedBox(width: 12),
        const Text("Stock Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _openProductForm(),
          icon: const Icon(Icons.add, size: 16),
          label: const Text("Add New Product"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // --- SUMMARY CARDS ---
  Widget _buildSummaryCards() {
    return Row(
      children: [
        _statCard("Total Categories", "12", Colors.blue),
        const SizedBox(width: 12),
        _statCard("Low Stock Items", "8", Colors.orange),
        const SizedBox(width: 12),
        _statCard("Out of Stock", "2", Colors.red),
      ],
    );
  }

  // --- ACTION BAR ---
  Widget _buildActionBar() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name or SKU...",
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _iconBtn(Icons.filter_list_rounded),
        const SizedBox(width: 8),
        _iconBtn(Icons.file_download_outlined),
      ],
    );
  }

  // --- TABLE ---
  Widget _buildTableContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1000),
              child: DataTable(
                headingRowHeight: 50,
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                columns: const [
                  DataColumn(label: Text('Product Name')),
                  DataColumn(label: Text('SKU')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _inventory.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> item = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(item['sku'])),
                    DataCell(Text(item['category'])),
                    DataCell(_buildStockBadge(item['stock'])),
                    DataCell(Text("\$${item['price']}")),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _openProductForm(product: item, index: idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          onPressed: () => setState(() => _inventory.removeAt(idx)),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- FORM DRAWER UI ---
  Widget _buildProductForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_isEditing ? "Update Product" : "New Product",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 30),
            _inputLabel("Product Name"),
            _textInput(_nameController, "Enter product name"),
            const SizedBox(height: 20),
            _inputLabel("SKU Code"),
            _textInput(_skuController, "Enter SKU"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _inputLabel("Price"),
                  _textInput(_priceController, "0.00", isNum: true),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _inputLabel("Stock"),
                  _textInput(_stockController, "0", isNum: true),
                ])),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      final data = {
                        "name": _nameController.text,
                        "sku": _skuController.text,
                        "category": "General",
                        "stock": int.parse(_stockController.text),
                        "price": _priceController.text,
                      };
                      if (_isEditing) {
                        _inventory[_editingIndex!] = data;
                      } else {
                        _inventory.add(data);
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(_isEditing ? "Update Stock" : "Create Product"),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---
  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(int stock) {
    bool isLow = stock < 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "$stock pcs",
        style: TextStyle(color: isLow ? Colors.red : Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _inputLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _textInput(TextEditingController ctrl, String hint, {bool isNum = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _iconBtn(IconData icon) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
    child: IconButton(icon: Icon(icon, size: 20), onPressed: () {}),
  );
  
}