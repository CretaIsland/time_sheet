//import 'package:flutter/foundation.dart';
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final logger = Logger('App');

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void setupLogger() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((record) {
    String emoji = '';
    if (record.level == Level.INFO) {
      emoji = 'ℹ️';
    } else if (record.level == Level.WARNING) {
      emoji = '❗️';
    } else if (record.level == Level.SEVERE) {
      emoji = '⛔️';
    }
    debugPrint('$emoji   ${record.level.name}: ${record.message}');
    if (record.error != null) {
      debugPrint('👉 ${record.error}');
    }
    if (record.level == Level.SEVERE) {
      debugPrint('👉 ${record.error}');
      //debugPrintStack(stackTrace: record.stackTrace);
    }
  });
}
