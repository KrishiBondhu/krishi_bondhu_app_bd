// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:krishi_bondhu_app_bd/screens/settings/change_password_screen.dart';
import 'package:krishi_bondhu_app_bd/screens/settings/profile_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সেটিংস'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('প্রোফাইল'),
            subtitle: const Text('আপনার জেলা এবং উপজেলা আপডেট করুন'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('পাসওয়ার্ড পরিবর্তন করুন'),
            subtitle: const Text('আপনার অ্যাকাউন্ট পাসওয়ার্ড আপডেট করুন'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('নোটিফিকেশন'),
            subtitle: const Text('অ্যাপ নোটিফিকেশন পরিচালনা করুন'),
            onTap: () {
              // Not implemented yet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ফিচার খুব শীঘ্রই আসছে!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
