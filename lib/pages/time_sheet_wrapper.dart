// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';

import 'project_choice.dart';
import 'time_sheet_page.dart';

GlobalKey<TimeSheetWrapperState> tsGlobalKey = GlobalKey<TimeSheetWrapperState>();

class TimeSheetWrapper extends StatefulWidget {
  static double drawerWidth = 250;

  const TimeSheetWrapper({super.key});

  @override
  State<TimeSheetWrapper> createState() => TimeSheetWrapperState();
}

class TimeSheetWrapperState extends State<TimeSheetWrapper> {
  double _tweenValue = 0;

  void openDrawer() {
    setState(() {
      _tweenValue = 1;
    });
  }

  void closeDrawer() {
    if (_tweenValue == 1) {
      setState(() {
        _tweenValue = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              //color: Colors.blue.withOpacity(0.2),
              gradient: LinearGradient(colors: [
            Colors.blue.withOpacity(0.2),
            Colors.blue.withOpacity(0.3),
            Colors.blue.withOpacity(0.4),
            Colors.blue.withOpacity(0.5),
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter)
              //image: DecorationImage(image: AssetImage('assets/blurLight.jpg'), fit: BoxFit.fill),
              ),
        ),
        projectChoiceDrawer(),
        TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: _tweenValue),
            duration: Duration(milliseconds: 250),
            curve: Curves.easeIn,
            builder: (_, double val, __) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..setEntry(0, 3, TimeSheetWrapper.drawerWidth * val)
                  ..rotateY((pi / 6) * val),
                child: TimeSheetPage(),
              );
            }),
      ],
    );
  }

  Widget projectChoiceDrawer() {
    return Material(
      child: SafeArea(
          child: Container(
        color: Colors.white,
        height: double.infinity,
        width: TimeSheetWrapper.drawerWidth,
        padding: EdgeInsets.all(8),
        child: ProjectChoice(),
      )),
    );
  }
}
