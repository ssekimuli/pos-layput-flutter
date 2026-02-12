import 'package:flutter/material.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();

  bool _isEditing = false;
  int? _editingIndex;

  // Mock Data Source
  final List<Map<String, dynamic>> _departments = [
    {'name': 'Sales', 'employees': 12, 'icon': Icons.trending_up},
    {'name': 'Marketing', 'employees': 8, 'icon': Icons.campaign},
    {'name': 'IT Support', 'employees': 5, 'icon': Icons.support_agent},
    {'name': 'Human Resources', 'employees': 4, 'icon': Icons.people},
    {'name': 'Accounting', 'employees': 6, 'icon': Icons.account_balance},
    {'name': 'Operations', 'employees': 15, 'icon': Icons.settings_applications},
  ];

  void _openDepartmentForm({Map<String, dynamic>? department, int? index}) {
    setState(() {
      if (department != null) {
        _isEditing = true;
        _editingIndex = index;
        _nameController.text = department['name'];
      } else {
        _isEditing = false;
        _editingIndex = null;
        _nameController.clear();
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
        child: _buildDepartmentForm(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(child: _buildDepartmentGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.corporate_fare_rounded, color: Color(0xFF006070), size: 28),
        const SizedBox(width: 12),
        const Text("Departments", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _openDepartmentForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text("Add Department"),
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

  Widget _buildDepartmentGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        childAspectRatio: 1.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: _departments.length,
      itemBuilder: (context, index) {
        final dept = _departments[index];
        return _buildDepartmentCard(dept, index);
      },
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> dept, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(dept['icon'], size: 32, color: Colors.blue.shade800),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _openDepartmentForm(department: dept, index: index);
                  } else if (value == 'delete') {
                    setState(() => _departments.removeAt(index));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text("Edit")),
                  const PopupMenuItem(value: 'delete', child: Text("Delete")),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dept['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("${dept['employees']} Employees", style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentForm() {
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
                Text(_isEditing ? "Update Department" : "New Department", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 30),
            _inputLabel("Department Name"),
            _textInput(_nameController, "Enter department name"),
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
                          'employees': _isEditing ? _departments[_editingIndex!]['employees'] : 0,
                          'icon': _isEditing ? _departments[_editingIndex!]['icon'] : Icons.business,
                        };
                        if (_isEditing) {
                          _departments[_editingIndex!] = data;
                        } else {
                          _departments.add(data);
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
}