import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Standard Theme Colors
    const Color accentOrange = Colors.orange;
    
    // Modern Deep Color Palette
    const Color primaryDeep = Color(0xFF0F172A); // Midnight Navy
    const Color secondaryDeep = Color(0xFF1E293B); // Slate Blue

    return Scaffold(
      // The scaffold background is overridden by the Container gradient
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Deep Navy Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryDeep,
                  secondaryDeep,
                ],
              ),
            ),
          ),

          // 2. Main Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Welcome!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      width: 60,
                      decoration: BoxDecoration(
                        color: accentOrange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // 3. The Grid (Fits 1100x600 perfectly)
                    Flexible(
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 1, 
                        mainAxisSpacing: 1,
                        childAspectRatio: 1.8, 
                        children: [
                          _buildDashCard(Icons.vpn_key_outlined, "Register", primaryDeep),
                          _buildDashCard(Icons.storefront_outlined, "Store Status", accentOrange),
                          _buildDashCard(Icons.menu_book_outlined, "Pricebook", Colors.redAccent),
                          _buildDashCard(Icons.group_outlined, "Vendors", Colors.purpleAccent),
                          _buildDashCard(Icons.person_outline, "Users", Colors.greenAccent),
                          _buildDashCard(Icons.access_time, "Time Clock", Colors.blueGrey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashCard(IconData icon, String label, Color iconColor) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Add Navigation Logic
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: iconColor),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155), // Dark Slate Text
              ),
            ),
          ],
        ),
      ),
    );
  }
}