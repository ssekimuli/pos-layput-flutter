import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'features/pos/screens/pos_layout.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(1024, 600); // Reduced height as requested
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "POS Desktop";
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        body: Column(
          children: [
            // THE CUSTOM ORANGE TITLE BAR
            Container(
              height: 50, // Increased height
              color: Colors.orange,
              child: WindowTitleBarBox(
                child: Row(
                  children: [
                    if (Platform.isMacOS) const SizedBox(width: 80),
                    
                    // 1. The White Title Text
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "POS DESKTOP SYSTEM",
                        style: TextStyle(
                          color: Colors.white, // White title
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // 2. The Draggable Area (Fills the middle)
                    Expanded(
                      child: MoveWindow(),
                    ),

                    // 3. Window Buttons
                    if (Platform.isWindows) const WindowButtons(),
                  ],
                ),
              ),
            ),
            const Expanded(child: POSLayout()),
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