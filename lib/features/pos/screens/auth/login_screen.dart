import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. KEEPING YOUR ORIGINAL LOGIC
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isPasswordMode = true;

  void _handleLogin() {
    // Validating credentials exactly like your original code
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter credentials"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      body: Row(
        children: [
          // Left Branding Side
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                      children: [
                        TextSpan(text: "Modern ", style: TextStyle(color: Colors.orange)),
                        TextSpan(text: "POS\nMade Simple"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Fast, secure, and built for growth.",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Right Form Side
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1E21),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text("Welcome Back", 
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 30),

                    // Inputs using your Controllers
                    _buildLabel("Username"),
                    _buildTextField(
                      controller: _usernameController, 
                      hint: "Enter username", 
                      icon: Icons.person_outline
                    ),
                    
                    const SizedBox(height: 20),
                    _buildLabel("Password"),
                    _buildTextField(
                      controller: _passwordController, 
                      hint: "••••••••", 
                      icon: Icons.lock_outline, 
                      isPassword: true
                    ),

                    const SizedBox(height: 30),

                    // 2. UPDATED BUTTON: Calls your _handleLogin
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _handleLogin,
                        child: const Text("Sign In", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.black12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: const BorderSide(color: Colors.white12)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: const BorderSide(color: Colors.orange)
        ),
      ),
    );
  }
}