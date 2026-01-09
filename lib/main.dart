import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'features/pos/screens/pos_layout.dart';

void main() {
  runApp(const MyApp());

  // Set initial window size for Desktop
  doWhenWindowReady(() {
   const initialSize = Size(1024, 600);
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
      // Use a Theme to keep your orange color consistent
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        body: Column(
          children: [
            // THE CUSTOM ORANGE TITLE BAR
            Container(
              color: Colors.orange, // Standardize color here
              child: WindowTitleBarBox(
                child: Row(
                  children: [
                    if (Platform.isMacOS) const SizedBox(width: 80), 
                    Expanded(child: MoveWindow()), // Allows dragging
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
    // Fixed: changed 'buttonNormal' to 'normal'
    final colors = WindowButtonColors(
      iconNormal: Colors.white,
      mouseOver: Colors.orange[700],
      mouseDown: Colors.orange[800],
      normal: Colors.orange, // Corrected parameter
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: Colors.white,
      normal: Colors.orange, // Corrected parameter
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