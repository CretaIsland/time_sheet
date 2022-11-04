// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:time_sheet/routes.dart';

import '../common/creta_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return CretaScaffold(
      title: 'Creta Login',
      context: context,
      child: Center(
        child: ElevatedButton(
          child: Text("Login"),
          onPressed: () {
            AppRoutes.push(context, AppRoutes.timeSheetPage);
          },
        ),
      ),
    ).create();
  }
}// TODO Implement this library.