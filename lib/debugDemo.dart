import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: AppHome()));
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: OutlinedButton(
          onPressed: () {
            debugDumpApp();
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(20),
          ),
          child: const Text('Dump Widget Tree'),
        ),
      ),
    );
  }
}
