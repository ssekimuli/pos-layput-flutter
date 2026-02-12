import 'package:flutter/material.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isEditing = false;
  int? _editingIndex;

  // Mock Data Source
  final List<Map<String, dynamic>> _customers = List.generate(10, (index) => {
    'name': 'Customer ${index + 1}',
    'email': 'customer${index + 1}@example.com',
    'phone': '123-456-789$index',
    'address': '123 Main St, Anytown, USA',
    'spent': 150.00 + (index * 50),
  });

  void _openCustomerForm({Map<String, dynamic>? customer, int? index}) {
    setState(() {
      if (customer != null) {
        _isEditing = true;
        _editingIndex = index;
        _nameController.text = customer['name'];
        _emailController.text = customer['email'];
        _phoneController.text = customer['phone'];
        _addressController.text = customer['address'];
      } else {
        _isEditing = false;
        _editingIndex = null;
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
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
        child: _buildCustomerForm(),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded, color: Color(0xFF006070), size: 28),
          const SizedBox(width: 12),
          const Text("Customer Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _openCustomerForm,
            icon: const Icon(Icons.add, size: 16),
            label: const Text("Add Customer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
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
                hintText: "Search by name or email...",
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
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Total Spent')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _customers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> item = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(item['email'])),
                    DataCell(Text(item['phone'])),
                    DataCell(Text("\$${item['spent'].toStringAsFixed(2)}")),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _openCustomerForm(customer: item, index: idx)),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => setState(() => _customers.removeAt(idx))),
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

  Widget _buildCustomerForm() {
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
                Text(_isEditing ? "Update Customer" : "New Customer", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 30),
            _inputLabel("Full Name"),
            _textInput(_nameController, "Enter full name"),
            const SizedBox(height: 20),
            _inputLabel("Email Address"),
            _textInput(_emailController, "Enter email"),
            const SizedBox(height: 20),
            _inputLabel("Phone Number"),
            _textInput(_phoneController, "Enter phone number"),
            const SizedBox(height: 20),
            _inputLabel("Address"),
            _textInput(_addressController, "Enter address"),
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
                          'name': _nameController.text,
                          'email': _emailController.text,
                          'phone': _phoneController.text,
                          'address': _addressController.text,
                          'spent': _isEditing ? _customers[_editingIndex!]['spent'] : 0.0,
                        };
                        if (_isEditing) {
                          _customers[_editingIndex!] = data;
                        } else {
                          _customers.insert(0, data);
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

  Widget _inputLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _textInput(TextEditingController ctrl, String hint) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
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