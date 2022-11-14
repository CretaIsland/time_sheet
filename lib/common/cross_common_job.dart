import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cross_common_job_stub.dart'
    if (dart.library.io) 'cross_common_job_mobile.dart'
    if (dart.library.html) 'cross_common_job_web.dart';

abstract class CrossCommonJob {
  void changeHttpWithCredentials(http.Client client);
  void fixEdgePasswordRevealButton(FocusNode focusNode);
  bool isSupportLocalStorage();

  factory CrossCommonJob() => getCrossCommonJob();
}
