import 'package:flutter/material.dart';

void main() {
  runApp(const DeltaApp());
}

class DeltaApp extends StatelessWidget {
  const DeltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Δ-Silicon',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const Scaffold(
        body: Center(child: Text('Step 0 ✅ – Codespaces Ready')),
      ),
    );
  }
}
