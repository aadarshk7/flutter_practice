import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  void initState() {
    super.initState();
    // Fetch tokens when dialog is opened
    context.read<SettingsCubit>().fetchTokens();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.error != null) {
          // Show error in a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) {
          // Force rebuild on any state change
          return true;
        },
        builder: (context, state) {
          developer.log('Building dialog with ${state.tokens.length} tokens', name: 'SettingsDialog');

          return AlertDialog(
            title: const Text('Live Share Tokens'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400, // Fixed height to make scrolling work better
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Text('Error: ${state.error}', style: TextStyle(color: Colors.red))
                      : state.tokens.isEmpty
                          ? const Text('No tokens available')
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.tokens.length,
                              itemBuilder: (context, index) {
                                final token = state.tokens[index];
                                final isEnabled = !token.disabled;

                                developer.log('Building token ${token.id}, disabled=${token.disabled}', name: 'SettingsDialog');

                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: SwitchListTile(
                                    title: Text('Token ID: ${token.id}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Status: ${isEnabled ? "Enabled" : "Disabled"}'),
                                        Text('Expires: ${_formatDate(token.expiresAt)}'),
                                        Text('Created: ${_formatDate(token.createdAt)}'),
                                      ],
                                    ),
                                    value: isEnabled,
                                    activeColor: Colors.green,
                                    inactiveTrackColor: Colors.red.withOpacity(0.5),
                                    onChanged: (bool value) {
                                      developer.log('Switch toggled for token ${token.id} to value $value', name: 'SettingsDialog');

                                      // Show immediate feedback to user
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${value ? "Enabling" : "Disabling"} token ${token.id}...'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );

                                      context.read<SettingsCubit>().toggleToken(token);
                                    },
                                  ),
                                );
                              },
                            ),
            ),
            actions: <Widget>[
              if (state.isLoading)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Updating...'),
                ),
              if (state.error != null)
                TextButton(
                  child: const Text('RETRY'),
                  onPressed: () {
                    developer.log('Retry button pressed', name: 'SettingsDialog');
                    context.read<SettingsCubit>().fetchTokens();
                  },
                ),
              TextButton(
                child: const Text('CLOSE'),
                onPressed: () {
                  developer.log('Close button pressed', name: 'SettingsDialog');
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
