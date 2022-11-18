// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:time_sheet/common/sqlite_wapper.dart';
import 'package:time_sheet/model/slot_manager.dart';
import '../../routes.dart';
import '../model/data_model.dart';
import 'logger.dart';
import 'utils.dart';

class CretaScaffold {
  final String title;
  final BuildContext context;
  final Widget child;
  final GlobalKey gkey = GlobalKey();
  List<Widget>? actions;
  Widget? leading;
  void Function()? gotoLeft;
  void Function()? gotoRight;
  void Function()? refreshProject;
  void Function()? copyYesterday;

  CretaScaffold({
    required this.title,
    required this.context,
    required this.child,
    this.actions,
    this.leading,
    this.gotoLeft,
    this.gotoRight,
    this.refreshProject,
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
        children: _timeSheetPageDial(context),
      );
    }
    return null;
  }

  List<SpeedDialChild> _timeSheetPageDial(BuildContext context) {
    return [
      //  SpeedDialChild(
      //   child: Icon(Icons.refresh_outlined),
      //   label: '프로젝트 목록 다시 가져오기',
      //   onTap: refreshProject,
      // ),
      SpeedDialChild(
        child: Icon(Icons.copy_outlined),
        label: '어제 것으로 복사하기',
        onTap: () {
          _copyYesterDay();
        },
      ),
      SpeedDialChild(
        child: Icon(Icons.exit_to_app),
        label: '끝내기',
        onTap: () async {
          bool isOK = await yesNoDialog(context, "정말로 앱을 끝내시겠습니까 ?");
          if (isOK == true) {
            SystemNavigator.pop();
          }
        },
      ),
      SpeedDialChild(
        child: Icon(Icons.logout_outlined),
        label: '로그 아웃',
        onTap: () async {
          await SqliteWrapper.clearAutologinInfo();
          AppRoutes.push(gkey.currentContext!, AppRoutes.login);
        },
      ),
    ];
  }

// List<SpeedDialChild> _getDialList(BuildContext context) {
//     List<SpeedDialChild> retval = [];
//     if (AppRoutes.isCurrentPage(context, AppRoutes.timeSheetPage)) {
//       // retval.add(SpeedDialChild(
//       //   child: Icon(Icons.refresh_outlined),
//       //   label: '프로젝트 목록 다시 가져오기',
//       //   onTap: refreshProject,
//       // ));
//       retval.add(SpeedDialChild(
//         child: Icon(Icons.copy_outlined),
//         label: '어제 것으로 복사하기',
//         onTap: () {
//           _copyYesterDay();
//         },
//       ));
//       retval.add(SpeedDialChild(
//         child: Icon(Icons.exit_to_app),
//         label: '끝내기',
//         onTap: () async {
//           bool isOK = await yesNoDialog(context, "정말로 앱을 끝내시겠습니까 ?");
//           if (isOK == true) {
//             SystemNavigator.pop();
//           }
//           // //AppRoutes.pop(context);
//           // AppRoutes.push(gkey.currentContext!, AppRoutes.calendarPage);
//         },
//       ));
//       retval.add(SpeedDialChild(
//         child: Icon(Icons.logout_outlined),
//         label: '로그 아웃',
//         onTap: () async {
//           await SqliteWrapper.clearAutologinInfo();
//           AppRoutes.push(gkey.currentContext!, AppRoutes.login);
//         },
//       ));
//     }

//     return retval;
//   }

  void _copyYesterDay() async {
    logger.finest('currentDate is ${slotManagerHolder!.currentDate}');
    DateTime curentDate = DateTime.parse(slotManagerHolder!.currentDate);
    DateTime yesterday = curentDate.subtract(Duration(days: 1));
    String yesterdayStr = DataManager.formatter.format(yesterday);
    if (slotManagerHolder!.currentDate == yesterdayStr) {
      // 썸머타임때문에 같은날짜가 될 수 있다.  만약 같다면 하루 더 뺀다.
      yesterday = yesterday.subtract(Duration(days: 1));
      yesterdayStr = DataManager.formatter.format(yesterday);
    }
    List<TimeSlotModel> yesterDayList = slotManagerHolder!.getDate(yesterdayStr);
    logger.finest('yesterday is $yesterdayStr');
    await slotManagerHolder!.copyToCurrentDate(yesterDayList);
    slotManagerHolder!.notify();
  }
}
