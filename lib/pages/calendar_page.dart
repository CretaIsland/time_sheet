import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:routemaster/routemaster.dart';
//import 'package:intl/intl.dart';

import '../common/creta_scaffold.dart';
import '../common/table_calendar.dart';
import '../common/logger.dart';
import '../routes.dart';
import 'package:time_sheet/model/data_model.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  final Set<DateTime> _completeDays = {};
  final Set<DateTime> _incompleteDays = {};

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // setState(() {
    //   if (_completeDays.contains(selectedDay)) {
    //     _completeDays.remove(selectedDay);
    //   } else {
    //     _completeDays.add(selectedDay);
    //   }
    //
    //   // _focusedDay = focusedDay;
    //   //
    //   // _focusedDay.value = focusedDay;
    //   // _rangeStart = null;
    //   // _rangeEnd = null;
    //   // _rangeSelectionMode = RangeSelectionMode.toggledOff;
    // });
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String selDayStr = formatter.format(selectedDay);
    if (DateTime.parse(selDayStr).compareTo(DateTime.now()) <= 0) {
      DataManager.showDate = selDayStr;
      AppRoutes.push(context, AppRoutes.calendarPage, AppRoutes.timeSheetPage);
      //Routemaster.of(context).push(AppRoutes.timeSheetPage);
    } else {
      showSnackBar(context, '차후 일정은 미리 설정할 수 없습니다');
    }
  }

  void onTodayButtonTap() {
    //setState(() => _focusedDay = DateTime.now());
    _focusedDay = DateTime.now();
  }

  @override
  void initState() {
    super.initState();

    // DateTime now = DateTime.now();
    // int nowYear = now.year;
    // int nowMonth = now.month;
    // int nowDay = now.day;
    //
    // for (int i = 1; i < nowDay - 1; i++) {
    //   DateTime monthDay = DateTime(nowYear, nowMonth, i);
    //   _completeDays.add(monthDay);
    // }

    for (var alarm in DataManager.alarmList) {
      DateTime alarmDay = DateTime.parse(alarm.date);
      _incompleteDays.add(alarmDay);
      _completeDays.removeWhere((day) => day.compareTo(alarmDay) == 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CretaScaffold(
      title: 'Calendar pages',
      context: context,
      //actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings))],
      leading: IconButton(
          onPressed: () {
            //AppRoutes.pop(context);
            AppRoutes.push(context, AppRoutes.calendarPage, AppRoutes.timeSheetPage);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.amber,
          )),
      child: TableCalendarWidget(_focusedDay, _completeDays, _incompleteDays,
              onDaySelected: onDaySelected, onTodayButtonTap: onTodayButtonTap)
          .build(),
    ).create();
  }
}
