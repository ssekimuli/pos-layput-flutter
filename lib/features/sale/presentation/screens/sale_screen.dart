import 'package:flutter/material.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedStatus;

  bool _isEditing = false;
  int? _editingIndex;

  // Mock Data Source
  final List<Map<String, dynamic>> _sales = List.generate(12, (index) => {
    'invoice_id': 'INV-2024-${(index + 1).toString().padLeft(4, '0')}',
    'customer': 'Customer ${index + 1}',
    'date': '2024-07-${20 - index}',
    'amount': 150.00 + (index * 25),
    'status': ['Paid', 'Pending', 'Overdue'][index % 3],
  });

  final List<String> _statuses = ['Paid', 'Pending', 'Overdue'];

  void _openSaleForm({Map<String, dynamic>? sale, int? index}) {
    setState(() {
      if (sale != null) {
        _isEditing = true;
        _editingIndex = index;
        _customerController.text = sale['customer'];
        _amountController.text = sale['amount'].toString();
        _dateController.text = sale['date'];
        _selectedStatus = sale['status'];
      } else {
        _isEditing = false;
        _editingIndex = null;
        _customerController.clear();
        _amountController.clear();
        _dateController.text = DateTime.now().toIso8601String().substring(0, 10);
        _selectedStatus = null;
      }
    });
    _scaffoldKey.currentState!.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      endDrawer: Drawer(
        width: 400,
        child: _buildSaleForm(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildActionBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildTableContainer()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.point_of_sale_rounded, color: Color(0xFF006070), size: 28),
        const SizedBox(width: 12),
        const Text("Sales Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _openSaleForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text("Create Sale"),
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
                hintText: "Search by invoice ID or customer...",
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
        _iconBtn(Icons.filter_list_rounded, "Filter"),
        const SizedBox(width: 8),
        _iconBtn(Icons.file_download_outlined, "Export"),
      ],
    );
  }

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
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.hovered) ? Colors.grey.shade100 : null),
                columns: const [
                  DataColumn(label: Text('Invoice ID')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _sales.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> item = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(item['invoice_id'], style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(item['customer'])),
                    DataCell(Text(item['date'])),
                    DataCell(Text("\$${item['amount'].toStringAsFixed(2)}")),
                    DataCell(_buildStatusBadge(item['status'])),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _openSaleForm(sale: item, index: idx)),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => setState(() => _sales.removeAt(idx))),
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

  Widget _buildSaleForm() {
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
                Text(_isEditing ? "Edit Sale" : "Create New Sale", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 30),
            _inputLabel("Customer Name"),
            _textInput(_customerController, "Enter customer name"),
            const SizedBox(height: 20),
            _inputLabel("Sale Date"),
            _textInput(_dateController, "YYYY-MM-DD"),
            const SizedBox(height: 20),
             _inputLabel("Status"),
            _statusDropdown(),
            const SizedBox(height: 20),
            _inputLabel("Amount"),
            _textInput(_amountController, "0.00", isNum: true),
            const Spacer(),
            Row(
              children: [
                Expanded(child: SizedBox(height: 50, child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")))),
                const SizedBox(width: 16),
                Expanded(child: SizedBox(height: 50, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        final data = {
                          'invoice_id': _isEditing ? _sales[_editingIndex!]['invoice_id'] : 'INV-2024-${(_sales.length + 1).toString().padLeft(4, '0')}',
                          'customer': _customerController.text,
                          'date': _dateController.text,
                          'status': _selectedStatus,
                          'amount': double.parse(_amountController.text),
                        };
                        if (_isEditing) {
                          _sales[_editingIndex!] = data;
                        } else {
                          _sales.insert(0, data);
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(_isEditing ? "Update" : "Create"),
                ))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color textColor;
    switch (status) {
      case 'Paid':
        color = Colors.green.shade50;
        textColor = Colors.green.shade800;
        break;
      case 'Pending':
        color = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        break;
      case 'Overdue':
        color = Colors.red.shade50;
        textColor = Colors.red.shade800;
        break;
      default:
        color = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
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

   Widget _statusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      hint: const Text("Select Status"),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => _selectedStatus = v),
      validator: (v) => v == null ? "Required" : null,
    );
  }

  Widget _iconBtn(IconData icon, String label) => TextButton.icon(
    onPressed: () {},
    icon: Icon(icon, size: 20),
    label: Text(label),
    style: TextButton.styleFrom(
      foregroundColor: Colors.grey.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      backgroundColor: Colors.white,
    ),
  );
}
