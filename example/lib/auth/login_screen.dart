// ignore_for_file: public_member_api_docs

import 'package:example/widgets/info_item.dart';
import 'package:flutter/material.dart';

import 'auth_model.dart';
import '../navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          if (navigationScheme.redirectedFrom != null)
            const InfoItem(
              title: 'Redirection',
              description:
                  '''You are redirected to this screen because of Settings screen requires user to be logged in.''',
              isDarkStyle: true,
            ),
          Expanded(
            child: Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: isLoggedIn,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoggedIn.value = !value;
                        if (isLoggedIn.value) {
                          navigationScheme.goBack();
                        }
                      });
                    },
                    child: Text(value ? 'Log out' : 'Log in'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
