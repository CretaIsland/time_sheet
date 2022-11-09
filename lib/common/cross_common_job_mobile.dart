import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cross_common_job.dart';

class CrossCommonJobMobile implements CrossCommonJob {

  @override
  void changeHttpWithCredentials(http.Client client) {
    // nothing
    return;
  }

  @override
  void fixEdgePasswordRevealButton(FocusNode focusNode) async {
    // nothing
    return;
  }
}

CrossCommonJob getCrossCommonJob() => CrossCommonJobMobile();
