// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../auth/auth_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: isLoggedIn,
          builder: (context, value, child) {
            return ElevatedButton(
              onPressed: () {
                isLoggedIn.value = !value;
              },
              child: Text(value ? 'Log out' : 'Log in'),
            );
          },
        ),
      ),
    );
  }
}
