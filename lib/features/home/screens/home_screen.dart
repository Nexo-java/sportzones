import 'package:flutter/material.dart';

/// Home screen - main dashboard
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SportZones')),
      body: const Center(
        child: Text('Home Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
