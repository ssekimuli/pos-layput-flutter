import 'package:flutter/material.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedStatus;

  bool _isEditing = false;
  int? _editingIndex;

  final List<String> _statuses = ['Paid', 'Pending', 'Overdue'];

  /// ---------------- MOCK DATA ----------------
  final List<Map<String, dynamic>> _sales =
      List.generate(12, (index) => {
            'invoice_id':
                'INV-2024-${(index + 1).toString().padLeft(4, '0')}',
            'customer': 'Customer ${index + 1}',
            'date': '2024-07-${20 - index}',
            'amount': 150.00 + (index * 25),
            'status': ['Paid', 'Pending', 'Overdue'][index % 3],
          });

  /// ---------------- OPEN MODAL ----------------
  void _openSaleForm({Map<String, dynamic>? sale, int? index}) {
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
      _dateController.text =
          DateTime.now().toIso8601String().substring(0, 10);
      _selectedStatus = null;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Rectangle modal
        ),
        child: Container(
          width: 650,
          padding: const EdgeInsets.all(20),
          child: _buildSaleForm(),
        ),
      ),
    );
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 15),
            _buildActionBar(),
            const SizedBox(height: 15),
            Expanded(child: _buildTable()),
          ],
        ),
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.point_of_sale,
            size: 22, color: Colors.black),
        const SizedBox(width: 10),
        const Text(
          "Sales Management",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _openSaleForm(),
          icon: const Icon(Icons.add, size: 16),
          label: const Text(
            "Create Sale",
            style: TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        )
      ],
    );
  }

  /// ---------------- ACTION BAR ----------------
  Widget _buildActionBar() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText:
                    "Search by invoice or customer...",
                hintStyle:
                    const TextStyle(fontSize: 12),
                prefixIcon:
                    const Icon(Icons.search, size: 16),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(
                        horizontal: 10),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _iconBtn(Icons.filter_list, "Filter"),
        const SizedBox(width: 6),
        _iconBtn(Icons.download, "Export"),
      ],
    );
  }

  /// ---------------- TABLE ----------------
  Widget _buildTable() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Colors.grey.shade300),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minWidth: 1200),
            child: DataTable(
              columnSpacing: 30,
              dataRowHeight: 42,
              headingRowHeight: 45,
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              columns: const [
                DataColumn(label: Text('Invoice ID')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows:
                  _sales.asMap().entries.map((entry) {
                int idx = entry.key;
                var item = entry.value;

                return DataRow(cells: [
                  DataCell(Text(item['invoice_id'],
                      style: const TextStyle(
                          fontSize: 12))),
                  DataCell(Text(item['customer'],
                      style: const TextStyle(
                          fontSize: 12))),
                  DataCell(Text(item['date'],
                      style: const TextStyle(
                          fontSize: 12))),
                  DataCell(Text(
                      "\$${item['amount'].toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 12))),
                  DataCell(
                      _statusChip(item['status'])),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 16),
                        onPressed: () =>
                            _openSaleForm(
                                sale: item,
                                index: idx),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 16,
                            color: Colors.red),
                        onPressed: () => setState(
                            () =>
                                _sales.removeAt(idx)),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- STATUS ----------------
  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case 'Paid':
        color = Colors.green;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius:
            BorderRadius.circular(2), // rectangle
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// ---------------- FORM ----------------
  Widget _buildSaleForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditing
                    ? "Edit Sale"
                    : "Create Sale",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  icon: const Icon(Icons.close,
                      size: 18))
            ],
          ),
          const SizedBox(height: 15),
          _input(_customerController,
              "Customer Name"),
          const SizedBox(height: 10),
          _input(_dateController, "Date"),
          const SizedBox(height: 10),
          _statusDropdown(),
          const SizedBox(height: 10),
          _input(_amountController, "Amount",
              isNumber: true),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black,
                      foregroundColor:
                          Colors.white,
                      shape:
                          const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.zero,
                      ),
                    ),
                    onPressed: _saveSale,
                    child: Text(
                      _isEditing
                          ? "Update"
                          : "Create",
                      style: const TextStyle(
                          fontSize: 12),
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

  void _saveSale() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'invoice_id': _isEditing
            ? _sales[_editingIndex!]
                ['invoice_id']
            : 'INV-2024-${(_sales.length + 1).toString().padLeft(4, '0')}',
        'customer':
            _customerController.text,
        'date': _dateController.text,
        'status': _selectedStatus,
        'amount': double.parse(
            _amountController.text),
      };

      setState(() {
        if (_isEditing) {
          _sales[_editingIndex!] = data;
        } else {
          _sales.insert(0, data);
        }
      });

      Navigator.pop(context);
    }
  }

  /// ---------------- INPUT ----------------
  Widget _input(TextEditingController c,
      String h,
      {bool isNumber = false}) {
    return SizedBox(
      height: 38,
      child: TextFormField(
        controller: c,
        keyboardType: isNumber
            ? TextInputType.number
            : null,
        style: const TextStyle(fontSize: 12),
        validator: (v) =>
            v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          hintText: h,
          hintStyle:
              const TextStyle(fontSize: 12),
          contentPadding:
              const EdgeInsets.symmetric(
                  horizontal: 10),
          filled: true,
          fillColor: Colors.white,
          border:
              const OutlineInputBorder(
            borderRadius:
                BorderRadius.zero,
          ),
        ),
      ),
    );
  }

  Widget _statusDropdown() {
    return SizedBox(
      height: 38,
      child: DropdownButtonFormField<String>(
        value: _selectedStatus,
        hint: const Text("Select Status",
            style: TextStyle(fontSize: 12)),
        items: _statuses
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e,
                    style: const TextStyle(
                        fontSize: 12))))
            .toList(),
        onChanged: (v) =>
            setState(() =>
                _selectedStatus = v),
        validator: (v) =>
            v == null ? "Required" : null,
        decoration:
            const InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              EdgeInsets.symmetric(
                  horizontal: 10),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.zero,
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(
      IconData icon, String label) {
    return SizedBox(
      height: 38,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(label,
            style:
                const TextStyle(fontSize: 12)),
        style: const ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.zero,
            ),
          ),
        ),
      ),
    );
  }
}
