// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../navigation.dart';

class HomeDialog extends StatelessWidget {
  const HomeDialog({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  final String title;

  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => navigationScheme.goBack(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
