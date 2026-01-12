import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'features/pos/screens/pos_layout.dart';
import 'features/pos/screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(1024, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "POS Desktop";
    appWindow.show();
  });
}

// Changed to StatefulWidget to manage login state
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false; // Tracks if the user is authenticated

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        body: Column(
          children: [
            // THE CUSTOM ORANGE TITLE BAR (Always visible)
            Container(
              height: 50,
              color: Colors.orange,
              child: WindowTitleBarBox(
                child: Row(
                  children: [
                    if (Platform.isMacOS) const SizedBox(width: 80),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "POS DESKTOP SYSTEM",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    Expanded(
                      child: MoveWindow(),
                    ),

                    if (Platform.isWindows) const WindowButtons(),
                  ],
                ),
              ),
            ),
            
            // DYNAMIC BODY: Logic to switch between Login and POS
            Expanded(
              child: _isLoggedIn 
                ? POSLayout(onLogout: () {
                    setState(() {
                      _isLoggedIn = false; // Handle logout
                    });
                  }) 
                : LoginScreen(onLoginSuccess: () {
                    setState(() {
                      _isLoggedIn = true; // Handle login success
                    });
                  }),
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
      mouseDown: Colors.orange[800],
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