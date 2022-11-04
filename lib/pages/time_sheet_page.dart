// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../common/creta_scaffold.dart';
import '../routes.dart';

class TimeSheetPage extends StatefulWidget {
  const TimeSheetPage({super.key});

  @override
  State<TimeSheetPage> createState() => _TimeSheetPageState();
}

class _TimeSheetPageState extends State<TimeSheetPage> {
  @override
  Widget build(BuildContext context) {
    return CretaScaffold(
      title: 'Creta Time Sheet',
      context: context,
      actions: [
        IconButton(
            onPressed: () {
              AppRoutes.push(context, AppRoutes.settingPage);
            },
            icon: Icon(Icons.settings))
      ],
      leading: IconButton(
          onPressed: () {
            //AppRoutes.pop(context);
            AppRoutes.push(context, AppRoutes.login);
          },
          icon: Icon(Icons.arrow_back)),
      child: Center(
        child: Text("Time Sheet Page"),
      ),
    ).create();
  }
}
