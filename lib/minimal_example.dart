import 'package:flutter/material.dart';

class MinimalExample extends StatelessWidget {
  const MinimalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Minimal Example')),
        body: const Center(
          child: Text('Flutter environment is working!'),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MinimalExample());
}
