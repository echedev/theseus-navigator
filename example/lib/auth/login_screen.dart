// ignore_for_file: public_member_api_docs

import 'package:example/navigation.dart';
import 'package:flutter/material.dart';

import 'auth_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isLoggedIn = !isLoggedIn;
              if (isLoggedIn) {
                navigationScheme.goBack();
              }
            });
          },
          child: Text(isLoggedIn ? 'Log out' : 'Log in'),
        ),
      ),
    );
  }
}
