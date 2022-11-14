import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'cross_common_job.dart';
import "package:universal_html/js.dart" as js;

class CrossCommonJobWeb implements CrossCommonJob {
  @override
  void changeHttpWithCredentials(http.Client client) {
    if (client is BrowserClient) {
      client.withCredentials = true;
    }
  }

  @override
  void fixEdgePasswordRevealButton(FocusNode focusNode) async {
    Future.microtask(() {
      focusNode.requestFocus();
      // 자바스크립트 호출
      /*dynamic ret = */ js.context.callMethod("fixPasswordCss", []); // index.html에서 fixPasswordCss 참조
    });
  }

  @override
  bool isSupportLocalStorage() {
    // sqflite do not support for web
    return false;
  }
}

CrossCommonJob getCrossCommonJob() => CrossCommonJobWeb();
