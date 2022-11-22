// ignore_for_file: prefer_const_constructors, avoid_print, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:time_sheet/pages/time_sheet_list.dart';
// import 'package:flutter_weather_bg_null_safety/bg/weather_bg.dart';
// import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';

import '../common/creta_scaffold.dart';
import '../common/logger.dart';
import '../model/data_model.dart';
import '../model/slot_manager.dart';
import '../routes.dart';
import 'time_sheet_wrapper.dart';

class TimeSheetPage extends StatefulWidget {
  const TimeSheetPage({super.key});

  @override
  State<TimeSheetPage> createState() => TimeSheetPageState();
}

class TimeSheetPageState extends State<TimeSheetPage> {
  int _dateMove = 0;
  //bool _refresh = false;
  //bool _moveToRight = false;
  //String? _showDate;
  String? _weekday;

  @override
  void initState() {
    slotManagerHolder = SlotManager();
    super.initState();
  }

  @override
  void dispose() {
    logger.finest('dispose TimeSheetPage');
    //alert?.dismiss();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _gotoDate();
    return ChangeNotifierProvider<SlotManager>.value(
        value: slotManagerHolder!,
        builder: (context, widget) {
          return CretaScaffold(
            refreshProject: () {
              DataManager.getProject();
              // setState(() {
              //   slotManagerHolder!.initCurrentDate();
              // });
            },
            title:
                DataManager.isUserLogin() ? '${DataManager.loginUser!.hm_name!}님' : 'Unknown user',
            context: context,
            actions: [
              IconButton(
                  onPressed: () async {
                    AppRoutes.lastPage = AppRoutes.timeSheetPage;
                    AppRoutes.push(context, AppRoutes.statPage);
                  },
                  icon: Icon(Icons.auto_graph_outlined))
            ],
            leading: AppRoutes.lastPage == AppRoutes.settingPage
                ? IconButton(
                    onPressed: () {
                      //AppRoutes.pop(context);
                      String toGo = AppRoutes.lastPage;
                      AppRoutes.lastPage = AppRoutes.timeSheetPage;
                      AppRoutes.push(context, toGo);
                    },
                    icon: Icon(Icons.arrow_back))
                : null,
            child: _mainPage(),
          ).create();
        });
  }

  Widget _mainPage() {
    return FutureBuilder<List<TimeSlotModel>>(
        future: _getTimeSheetData(context),
        builder: (context, AsyncSnapshot<List<TimeSlotModel>> snapshot) {
          if (snapshot.hasError) {
            //error가 발생하게 될 경우 반환하게 되는 부분
            logger.severe("data fetch error");
            return const Center(child: Text('data fetch error'));
          }
          if (snapshot.hasData == false) {
            //logger.severe("No data founded");
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            logger.finest("data founded ${snapshot.data!.length}...");
            // if (snapshot.data!.isEmpty) {
            //   return const Center(child: Text('no book founded'));
            // }
            return _drawPage(snapshot.data!);
          }
          return Container();
        });
  }

  Future<List<TimeSlotModel>> _getTimeSheetData(BuildContext context) async {
    logger.finest('_getTimeSheetData(${slotManagerHolder!.currentDate})');
    if (slotManagerHolder!.isNeverWritten(slotManagerHolder!.currentDate)) {
      await DataManager.getTimeSheet();
    }
    return slotManagerHolder!.getCurrentDate();
  }

  Widget _drawPage(List<TimeSlotModel> dailyList) {
    return Stack(
      children: [
        // LayoutBuilder(builder: (context, constraint) {
        //   return WeatherBg(
        //     weatherType: WeatherType.cloudy,
        //     width: constraint.maxWidth,
        //     height: constraint.maxHeight,
        //   );
        // }),
        Container(
          decoration: BoxDecoration(
              //color: Colors.blue.withOpacity(0.2),
              gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.2),
              Colors.blue.withOpacity(0.3),
              Colors.blue.withOpacity(0.4),
              Colors.blue.withOpacity(0.5),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          )
              //image: DecorationImage(image: AssetImage('assets/blurLight.jpg'), fit: BoxFit.fill),
              ),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: _dateView(),
              ),
              Expanded(
                  flex: 11,
                  //child: _timeSheetView(dailyList),
                  child: TimeSheetList(
                    key: timeSheetListGlobalKey,
                    dailyList: dailyList,
                  )),
              //),
            ],
          ),
        ),
      ],
    );
  }

  void _toPast() {
    tsGlobalKey.currentState?.closeDrawer();
    setState(() {
      _dateMove--;
      //_moveToRight = true;
      print('left to right $_dateMove');
    });
  }

  void _toFuture() {
    setState(() {
      _dateMove++;
      //_moveToRight = false;
      print('right to left $_dateMove');
    });
  }

  Widget _dateView() {
    return Container(
      color: Colors.transparent,
      alignment: AlignmentDirectional.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              onPressed: _toPast,
              icon: Icon(
                Icons.arrow_back_ios,
                size: 32,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _dateMove = 0;
                  });
                },
                child: Text(
                  '${slotManagerHolder!.currentDate}$_weekday',
                  style: TextStyle(
                    fontSize: 24,
                    color: _dateMove == 0 ? Colors.black : Colors.blue[500]!,
                  ),
                ),
              ),
              ElevatedButton(
                //visualDensity: VisualDensity.compact,
                onPressed: () {
                  AppRoutes.push(context, AppRoutes.calendarPage);
                },
                child: Icon(Icons.calendar_month),
                //padding: EdgeInsets.all(0),
              )
            ],
          ),
          (DataManager.getTodayString() != slotManagerHolder!.currentDate)
              ? IconButton(
                  onPressed: _toFuture,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 32,
                  ))
              : IconButton(
                  onPressed: () {},
                  icon: Icon(
                    color: Colors.grey[100]!,
                    Icons.arrow_forward_ios,
                    size: 32,
                  ))
        ],
      ),
    );
  }

  // Widget _timeSheetView(List<TimeSlotModel> dailyList) {
  //   //_createSample();
  //   ListView listView = ListView.builder(
  //     shrinkWrap: true,
  //     //initialItemCount: 15,
  //     itemCount: dailyList.length,
  //     itemBuilder: (
  //       context,
  //       index,
  //       /*animation*/
  //     ) {
  //       return Consumer<SlotManager>(builder: (context, slotManager, child) {
  //         logger.finest('_timeSheetView setState()');
  //         return TimeSlotItem(
  //           itemKey: GlobalKey<TimeSlotItemState>(),
  //           model: dailyList[index],
  //           //animation: animation,
  //           onCopy: () async {
  //             String? project1 = dailyList[index].projectCode1;
  //             String? project2 = dailyList[index].projectCode2;

  //             if (project1 != null && project2 == null) {
  //               project2 = project1;
  //               dailyList[index].projectCode2 = project1;
  //               dailyList[index].notifyUI =
  //                   await DataManager.saveTimeSheet(dailyList[index].timeSlot, project1, project2);
  //             }

  //             bool changed = false;
  //             for (int i = index + 1; i < dailyList.length; i++) {
  //               if (dailyList[i].timeSlot == '12') {
  //                 continue;
  //               }
  //               if (index < 12 && dailyList[i].timeSlot == '19') {
  //                 break; // 18시이후는 자동도배해주지 않는다.
  //               }
  //               if (dailyList[i].projectCode1 != null) {
  //                 break;
  //               }
  //               if (dailyList[i].projectCode2 != null) {
  //                 break;
  //               }

  //               if (project2 != null) {
  //                 dailyList[i].projectCode1 = project2;
  //                 dailyList[i].projectCode2 = project2;
  //                 changed = true;
  //               } else if (project1 != null) {
  //                 dailyList[index].projectCode2 = project1;
  //                 dailyList[i].projectCode1 = project1;
  //                 dailyList[i].projectCode2 = project1;
  //                 changed = true;
  //               }
  //               if (changed) {
  //                 dailyList[i].notifyUI = await DataManager.saveTimeSheet(dailyList[i].timeSlot,
  //                     dailyList[i].projectCode1 ?? '', dailyList[i].projectCode2 ?? '');
  //               }
  //             }
  //             if (changed) {
  //               slotManagerHolder!.notify();
  //             }
  //           },
  //         );
  //       });
  //     },
  //   );
  //   return listView;
  // }

  // List<Widget> _timeSheetView() {
  //   _createSample();
  //   return List.generate(15, (index) {
  //     return TimeSlotItem(
  //       item: dailyList[index],
  //       //animation: animation,
  //       onDelete: () {},
  //       onSplit: () {},
  //       onPaint: () {},
  //       onSaveClicked: () {},
  //     );
  //   });
  // }

  void _gotoDate() {
    DateTime now = DateTime.now();

    if (DataManager.showDate != null) {
      slotManagerHolder!.currentDate = DataManager.showDate!;
      DataManager.showDate = null;
      // now 와 today 와의 차이만큼 dateMove 값을 채워야함.
      DateTime tempDate = DateTime.parse(slotManagerHolder!.currentDate);
      Duration diff = tempDate.difference(now);
      // diff.inDays now 보다 과거면 음수가 나오고 미래면 양수가 나온다.
      _dateMove += diff.inDays;
    } else {
      if (_dateMove > 0) {
        now = now.add(Duration(days: _dateMove));
      }
      if (_dateMove < 0) {
        now = now.subtract(Duration(days: -1 * _dateMove));
      }
      slotManagerHolder!.currentDate = DataManager.formatter.format(now);
    }

    DateTime tempDate = DateTime.parse(slotManagerHolder!.currentDate);
    String weekTemp = DateFormat('EEEE').format(tempDate);

    switch (weekTemp) {
      case 'Monday':
        weekTemp = '월';
        break;
      case 'Tuesday':
        weekTemp = '화';
        break;
      case 'Wednesday':
        weekTemp = '수';
        break;
      case 'Thursday':
        weekTemp = '목';
        break;
      case 'Friday':
        weekTemp = '금';
        break;
      case 'Saturday':
        weekTemp = '토';
        break;
      case 'Sunday':
        weekTemp = '일';
        break;
    }
    _weekday = '($weekTemp)';
  }
}
