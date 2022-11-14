import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cross_common_job.dart';

class CrossCommonJobMobile implements CrossCommonJob {
  @override
  void changeHttpWithCredentials(http.Client client) {
    // do nothing
  }

  @override
  void fixEdgePasswordRevealButton(FocusNode focusNode) async {
    if (Platform.isAndroid) {
      // do nothing
    } else if (Platform.isIOS) {
      // do nothing
    } else if (Platform.isLinux) {
      // do nothing
    } else if (Platform.isMacOS) {
      // do nothing
    } else if (Platform.isWindows) {
      // do nothing
    } else {
      // do nothing
    }
  }

  @override
  bool isSupportLocalStorage() {
    if (Platform.isAndroid) {
      return true;
    } else if (Platform.isIOS) {
      return true;
    } else if (Platform.isLinux) {
      // do nothing
    } else if (Platform.isMacOS) {
      return true;
    } else if (Platform.isWindows) {
      // do nothing
    } else {
      // do nothing
    }
    return false;
  }
}

CrossCommonJob getCrossCommonJob() => CrossCommonJobMobile();
