import 'package:flutter/material.dart';
import '../widgets/geometric_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: GeometricBackground(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: [
              const ListTile(title: Text('Account'), subtitle: Text('Manage login & profile')),
              SwitchListTile(
                value: true,
                onChanged: (v) {},
                title: const Text('Enable email reminders'),
              ),
              ListTile(title: const Text('Theme'), subtitle: const Text('Soft fluid transitions')),
              ListTile(title: const Text('Security'), subtitle: const Text('JWT secure storage')),
              const SizedBox(height: 20),
              Center(child: ElevatedButton(onPressed: () {}, child: const Text('Sign out')))
            ],
          ),
        ),
      ),
    );
  }
}
