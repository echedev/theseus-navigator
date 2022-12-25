// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';

final topLevelNavigationType = ValueNotifier<TopLevelNavigationType>(TopLevelNavigationType.bottomMaterial3);

enum TopLevelNavigationType {
  bottom,
  bottomMaterial3,
  drawer,
  tabs,
}