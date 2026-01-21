import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  double _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Row(
              children: [
                Icon(Icons.settings, color: Colors.blueAccent, size: 28),
                SizedBox(width: 12),
                Text("Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          _sidebarTile(0, Icons.person_outline, "Account"),
          _sidebarTile(1, Icons.palette_outlined, "Appearance"),
          _sidebarTile(2, Icons.notifications_none, "Notifications"),
          _sidebarTile(3, Icons.storage_outlined, "Storage & Data"),
          const Divider(indent: 20, endIndent: 20, height: 40),
          _sidebarTile(4, Icons.help_outline, "Support"),
        ],
      ),
    );
  }

  Widget _sidebarTile(int index, IconData icon, String title) {
    bool selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selected: selected,
        selectedTileColor: Colors.blue.withOpacity(0.08),
        leading: Icon(icon, color: selected ? Colors.blueAccent : Colors.black54),
        title: Text(title, 
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.blueAccent : Colors.black87,
          )
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0: return _buildAccountPage();
      case 1: return _buildAppearancePage();
      default: return const Center(child: Text("Section under construction"));
    }
  }

  Widget _buildAccountPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header("Account Details", "Manage your personal information and security."),
        const SizedBox(height: 32),
        _buildSettingsCard([
          _settingRow("Profile Photo", const CircleAvatar(child: Icon(Icons.edit, size: 16))),
          _settingInput("Full Name", "Enter your name"),
          _settingInput("Email Address", "you@example.com"),
        ]),
        const SizedBox(height: 24),
        _header("Security", "Control your password and authentication."),
        const SizedBox(height: 16),
        _buildSettingsCard([
          ListTile(
            title: const Text("Two-Factor Authentication"),
            subtitle: const Text("Add an extra layer of security"),
            trailing: OutlinedButton(onPressed: () {}, child: const Text("Enable")),
          ),
        ]),
      ],
    );
  }

  Widget _buildAppearancePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header("Appearance", "Customize how the app looks on your screen."),
        const SizedBox(height: 32),
        _buildSettingsCard([
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Switch between light and dark themes"),
            value: _isDarkMode,
            onChanged: (v) => setState(() => _isDarkMode = v),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Font Size Scaling"),
                Slider(
                  value: _fontSize,
                  min: 10, max: 24,
                  onChanged: (v) => setState(() => _fontSize = v),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  // UI Helpers
  Widget _header(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      width: 800, // Fixed width for readability on large screens
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _settingRow(String label, Widget action) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: action,
    );
  }

  Widget _settingInput(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            flex: 5,
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}