import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

// Ensure these paths match your project structure
import 'package:pos_desktop_ui/features/auth/presentation/providers/auth_provider.dart';
import 'package:pos_desktop_ui/features/auth/presentation/screens/login_screen.dart';
import 'package:pos_desktop_ui/features/pos/presentation/screens/pos_layout.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));

  // Configure bitsdojo_window
  doWhenWindowReady(() {
    const initialSize = Size(1100, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "POS Desktop System";
    appWindow.show(); // Required because of BDW_HIDE_ON_STARTUP
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state from your Riverpod provider
    final isLoggedIn = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF4F7F9),
      ),
      home: Scaffold(
        body: Column(
          children: [
            // --- CUSTOM ORANGE TITLE BAR ---
            Container(
              height: 45,
              color: Colors.orange,
              child: WindowTitleBarBox(
                child: Row(
                  children: [
                    if (Platform.isMacOS) const SizedBox(width: 80),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(Icons.storefront, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "POS DESKTOP",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Draggable Area
                    Expanded(child: MoveWindow()),

                    // Windows Control Buttons
                    if (Platform.isWindows) const WindowButtons(),
                  ],
                ),
              ),
            ),
            
            // --- DYNAMIC BODY ---
            Expanded(
              child: isLoggedIn 
                ? const POSLayout() 
                : const LoginScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  
  @override
  Widget build(BuildContext context) {
    final colors = WindowButtonColors(
      iconNormal: Colors.white,
      mouseOver: Colors.orange[700],
      mouseDown: Colors.orange[900],
      normal: Colors.orange, 
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: Colors.white,
      normal: Colors.orange, 
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: colors),
        MaximizeWindowButton(colors: colors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}