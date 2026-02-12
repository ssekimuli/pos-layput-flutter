import 'package:flutter/material.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedStatus;

  bool _isEditing = false;
  int? _editingIndex;

  // Mock Data Source
  final List<Map<String, dynamic>> _suppliers = List.generate(8, (index) => {
    'name': 'Supplier ${index + 1}',
    'contact_person': 'Contact ${index + 1}',
    'email': 'supplier${index + 1}@example.com',
    'status': ['Active', 'Inactive'][index % 2],
  });

  final List<String> _statuses = ['Active', 'Inactive'];

  void _openSupplierForm({Map<String, dynamic>? supplier, int? index}) {
    setState(() {
      if (supplier != null) {
        _isEditing = true;
        _editingIndex = index;
        _nameController.text = supplier['name'];
        _contactController.text = supplier['contact_person'];
        _emailController.text = supplier['email'];
        _selectedStatus = supplier['status'];
      } else {
        _isEditing = false;
        _editingIndex = null;
        _nameController.clear();
        _contactController.clear();
        _emailController.clear();
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
        child: _buildSupplierForm(),
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
        const Icon(Icons.people_alt_rounded, color: Color(0xFF006070), size: 28),
        const SizedBox(width: 12),
        const Text("Supplier Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _openSupplierForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text("Add Supplier"),
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
                  DataColumn(label: Text('Supplier Name')),
                  DataColumn(label: Text('Contact Person')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _suppliers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> item = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(item['contact_person'])),
                    DataCell(Text(item['email'])),
                    DataCell(_buildStatusBadge(item['status'])),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _openSupplierForm(supplier: item, index: idx)),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => setState(() => _suppliers.removeAt(idx))),
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

  Widget _buildSupplierForm() {
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
                Text(_isEditing ? "Edit Supplier" : "Add New Supplier", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 30),
            _inputLabel("Supplier Name"),
            _textInput(_nameController, "Enter supplier name"),
            const SizedBox(height: 20),
            _inputLabel("Contact Person"),
            _textInput(_contactController, "Enter contact person"),
            const SizedBox(height: 20),
            _inputLabel("Email"),
            _textInput(_emailController, "Enter email address"),
            const SizedBox(height: 20),
            _inputLabel("Status"),
            _statusDropdown(),
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
                          'contact_person': _contactController.text,
                          'email': _emailController.text,
                          'status': _selectedStatus,
                        };
                        if (_isEditing) {
                          _suppliers[_editingIndex!] = data;
                        } else {
                          _suppliers.insert(0, data);
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(_isEditing ? "Update" : "Add"),
                ))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Active' ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
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
