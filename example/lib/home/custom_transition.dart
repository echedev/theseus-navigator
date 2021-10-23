// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class CustomTransitionScreen extends StatelessWidget {
  const CustomTransitionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Transition'),
      ),
      body: Container(
        color: Theme.of(context).accentColor,
      ),
    );
  }
}
