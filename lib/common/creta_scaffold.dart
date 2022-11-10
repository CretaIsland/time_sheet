// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../routes.dart';
import 'logger.dart';

class CretaScaffold {
  final String title;
  final BuildContext context;
  final Widget child;
  final GlobalKey gkey = GlobalKey();
  List<Widget>? actions;
  Widget? leading;
  void Function()? gotoLeft;
  void Function()? gotoRight;
  void Function()? refresh;
  void Function()? copyYesterday;

  CretaScaffold({
    required this.title,
    required this.context,
    required this.child,
    this.actions,
    this.leading,
    this.gotoLeft,
    this.gotoRight,
    this.refresh,
    this.copyYesterday,
  });

  Scaffold create() {
    return Scaffold(
      key: gkey,
      appBar: cretaAppBar(context, title, leading, actions),
      floatingActionButton: cretaDial(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: Container(
        //color: Colors.amber,
        child: child,
      ),
    );
  }

  PreferredSizeWidget cretaAppBar(
    BuildContext context,
    String title,
    Widget? leading,
    List<Widget>? actions,
  ) {
    return AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Center(child: Text(title)),
      elevation: 5,
      actions: actions,
      leading: leading,
    );
  }

  Widget? cretaDial(BuildContext context) {
    if (AppRoutes.isCurrentPage(context, AppRoutes.timeSheetPage)) {
      return SpeedDial(
        //key: GlobalKey(),
        //backgroundColor: Colors.blue[700]!,
        animatedIcon: AnimatedIcons.menu_close,
        children: _getDialList(context),
      );
    }
    return null;
  }

  List<SpeedDialChild> _getDialList(BuildContext context) {
    List<SpeedDialChild> retval = [];
    if (AppRoutes.isCurrentPage(context, AppRoutes.timeSheetPage)) {
      retval.add(SpeedDialChild(
        child: Icon(Icons.calendar_month_outlined),
        label: '데이터 다시 가져오기',
        onTap: refresh,
      ));
      retval.add(SpeedDialChild(
        child: Icon(Icons.copy_outlined),
        label: '어제 것으로 복사하기',
        onTap: () {
          showSnackBar(gkey.currentContext!, '아직 구현되지 않았음');
        },
      ));
      retval.add(SpeedDialChild(
        child: Icon(Icons.calendar_month),
        label: '달력으로 보기',
        onTap: () {
          //AppRoutes.pop(context);
          AppRoutes.push(gkey.currentContext!, AppRoutes.calendarPage);
        },
      ));
    }
    if (AppRoutes.isCurrentPage(context, AppRoutes.settingPage)) {
      retval.add(SpeedDialChild(
        child: Icon(Icons.refresh_outlined),
        label: '프로젝트 다시 가져오기',
        onTap: () {
          showSnackBar(gkey.currentContext!, '아직 구현되지 않았음');
        },
      ));
      retval.add(SpeedDialChild(
        child: Icon(Icons.arrow_back_outlined),
        label: '돌아가기',
        onTap: () {},
      ));
    }
    if (AppRoutes.isCurrentPage(context, AppRoutes.login)) {
      retval.add(SpeedDialChild(
        child: Icon(Icons.logout_outlined),
        label: 'logout 하기',
        onTap: () {
          showSnackBar(gkey.currentContext!, '아직 구현되지 않았음');
        },
      ));
      retval.add(SpeedDialChild(
        child: Icon(Icons.exit_to_app_outlined),
        label: '앱 끝내기',
        onTap: () {},
      ));
    }

    return retval;
  }
}
