// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'time_sheet_page.dart';
import 'time_sheet_wrapper.dart';

DrawerManager? drawerManagerHolder;

class DrawerManager extends ChangeNotifier {
  double _tweenValue = 0;
  double get tweenValue => _tweenValue;

  void openDrawer() {
    _tweenValue = 1;
    notifyListeners();
  }

  void closeDrawer() {
    if (_tweenValue == 1) {
      _tweenValue = 0;
      notifyListeners();
    }
  }
}

//GlobalKey<TweenValueWidgetState> tsGlobalKey = GlobalKey<TweenValueWidgetState>();

class TweenValueWidget extends StatefulWidget {
  const TweenValueWidget({super.key});

  @override
  State<TweenValueWidget> createState() => TweenValueWidgetState();
}

class TweenValueWidgetState extends State<TweenValueWidget> {
  // double _tweenValue = 0;

  // void openDrawer() {
  //   setState(() {
  //     _tweenValue = 1;
  //   });
  // }

  // void closeDrawer() {
  //   if (_tweenValue == 1) {
  //     setState(() {
  //       _tweenValue = 0;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawerManager>(builder: (context, drawerManager, child) {
      return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: drawerManager.tweenValue),
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
          });
    });
  }
}
