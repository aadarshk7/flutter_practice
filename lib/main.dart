import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_practice/features/settings/view/settings_dialog.dart';
import 'package:flutter_practice/presentations/isolates/isolate_example.dart';

import 'features/settings/cubit/settings_cubit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Practice')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('SHOW DIALOG'),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('ISOLATES EXAMPLE'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const IsolatesExample(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
