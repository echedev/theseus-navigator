// ignore_for_file: public_member_api_docs

import 'package:example/settings/index.dart';
import 'package:flutter/material.dart';

import '../auth/auth_model.dart';
import '../widgets/info_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    print('${widget.runtimeType}, initState():');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InfoItem(
              title: 'Login',
              description: '',
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
            InfoItem(
              title: 'Top level navigation',
              description: '',
              child: ValueListenableBuilder<TopLevelNavigationType>(
                valueListenable: topLevelNavigationType,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      RadioListTile<TopLevelNavigationType>(
                        title: const Text('Bottom navigation bar'),
                        value: TopLevelNavigationType.bottom,
                        groupValue: value,
                        onChanged: (value) => topLevelNavigationType.value = TopLevelNavigationType.bottom,
                      ),
                      RadioListTile<TopLevelNavigationType>(
                        title: const Text('Drawer'),
                        value: TopLevelNavigationType.drawer,
                        groupValue: value,
                        onChanged: (value) => topLevelNavigationType.value = TopLevelNavigationType.drawer,
                      ),
                      RadioListTile<TopLevelNavigationType>(
                        title: const Text('Tab bar'),
                        value: TopLevelNavigationType.tabs,
                        groupValue: value,
                        onChanged: (value) => topLevelNavigationType.value = TopLevelNavigationType.tabs,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
