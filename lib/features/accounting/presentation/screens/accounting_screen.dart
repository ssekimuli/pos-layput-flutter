import 'package:flutter/material.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key});

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedType;

  bool _isEditing = false;
  int? _editingIndex;

  // Mock Data Source
  final List<Map<String, dynamic>> _transactions = List.generate(20, (index) => {
    'date': '2024-07-${20 - index}',
    'description': 'Sale #${345 + index}',
    'type': (index % 3 == 0) ? 'Expense' : 'Income',
    'amount': (index % 3 == 0) ? -75.50 - (index * 5) : 250.00 + (index * 10),
  });

  final List<String> _transactionTypes = ["Income", "Expense"];

  void _openTransactionForm({Map<String, dynamic>? transaction, int? index}) {
    setState(() {
      if (transaction != null) {
        _isEditing = true;
        _editingIndex = index;
        _dateController.text = transaction['date'];
        _descriptionController.text = transaction['description'];
        _amountController.text = transaction['amount'].abs().toString();
        _selectedType = transaction['type'];
      } else {
        _isEditing = false;
        _editingIndex = null;
        _dateController.text = DateTime.now().toIso8601String().substring(0, 10);
        _descriptionController.clear();
        _amountController.clear();
        _selectedType = null;
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
        child: _buildTransactionForm(),
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
    double totalIncome = _transactions.where((t) => t['type'] == 'Income').fold(0, (p, c) => p + c['amount']);
    double totalExpense = _transactions.where((t) => t['type'] == 'Expense').fold(0, (p, c) => p + c['amount']);
    double netProfit = totalIncome + totalExpense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF006070), size: 28),
              const SizedBox(width: 12),
              const Text("Financial Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openTransactionForm,
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add Transaction"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statCard("Total Income", "\$${totalIncome.toStringAsFixed(2)}", Colors.green),
              const SizedBox(width: 12),
              _statCard("Total Expense", "\$${totalExpense.abs().toStringAsFixed(2)}", Colors.red),
              const SizedBox(width: 12),
              _statCard("Net Profit", "\$${netProfit.toStringAsFixed(2)}", netProfit > 0 ? Colors.blue : Colors.orange),
            ],
          ),
        ],
      ),
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
                hintText: "Search by description...",
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
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Amount', textAlign: TextAlign.right)),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _transactions.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> item = entry.value;
                  bool isIncome = item['type'] == 'Income';
                  return DataRow(cells: [
                    DataCell(Text(item['date'])),
                    DataCell(Text(item['description'], style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(_buildTypeBadge(item['type'])),
                    DataCell(Text("\$${item['amount'].toStringAsFixed(2)}", 
                      style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,)),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _openTransactionForm(transaction: item, index: idx)),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => setState(() => _transactions.removeAt(idx))),
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

  Widget _buildTransactionForm() {
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
                Text(_isEditing ? "Update Transaction" : "New Transaction", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 30),
            _inputLabel("Transaction Date"),
            _textInput(_dateController, "YYYY-MM-DD"),
            const SizedBox(height: 20),
            _inputLabel("Description"),
            _textInput(_descriptionController, "e.g., Office Supplies"),
            const SizedBox(height: 20),
            _inputLabel("Type"),
            _typeDropdown(),
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
                        double amount = double.parse(_amountController.text);
                        if (_selectedType == 'Expense') amount = -amount;
                        final data = {
                          "date": _dateController.text,
                          "description": _descriptionController.text,
                          "type": _selectedType,
                          "amount": amount,
                        };
                        if (_isEditing) {
                          _transactions[_editingIndex!] = data;
                        } else {
                          _transactions.insert(0, data);
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

  Widget _buildTypeBadge(String type) {
    bool isIncome = type == 'Income';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(type, style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _typeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      hint: const Text("Select Type"),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      items: _transactionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: (v) => setState(() => _selectedType = v),
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