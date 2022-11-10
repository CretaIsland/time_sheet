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
}

CrossCommonJob getCrossCommonJob() => CrossCommonJobMobile();
