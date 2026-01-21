import 'package:flutter/material.dart';

class OpenDrawer extends StatefulWidget {
  const OpenDrawer({super.key});

  @override
  State<OpenDrawer> createState() => _OpenDrawerState();
}

class _OpenDrawerState extends State<OpenDrawer> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Open Drawer Screen'),
    );
  }
}