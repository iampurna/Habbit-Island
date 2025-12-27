import 'package:flutter/material.dart';
import 'widgets/settings_row.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Account',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SettingsRow(
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () {},
          ),
          SettingsRow(
            icon: Icons.workspace_premium,
            title: 'Premium',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            onTap: () => Navigator.pushNamed(context, '/premium'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('App', style: Theme.of(context).textTheme.titleSmall),
          ),
          SettingsRow(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          SettingsRow(
            icon: Icons.palette_outlined,
            title: 'Theme',
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Support',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SettingsRow(
            icon: Icons.help_outline,
            title: 'Help & FAQ',
            onTap: () {},
          ),
          SettingsRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          SettingsRow(icon: Icons.info_outline, title: 'About', onTap: () {}),
          const Divider(),
          SettingsRow(
            icon: Icons.logout,
            title: 'Sign Out',
            titleColor: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
