import 'package:flutter/material.dart';

class HrmScreen extends StatelessWidget {
  const HrmScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HRM'),
      ),
      body: const Center(
        child: Text('HRM Screen'),
      ),
    );
  }
}
