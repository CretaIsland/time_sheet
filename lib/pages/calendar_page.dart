import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';

import '../common/creta_scaffold.dart';
import '../common/table_calendar.dart';
//import '../common/logger.dart';
import '../routes.dart';

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
    setState(() {
      if (_completeDays.contains(selectedDay)) {
        _completeDays.remove(selectedDay);
      } else {
        _completeDays.add(selectedDay);
      }

      // _focusedDay = focusedDay;
      //
      // _focusedDay.value = focusedDay;
      // _rangeStart = null;
      // _rangeEnd = null;
      // _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });
  }

  void onTodayButtonTap() {
    //setState(() => _focusedDay = DateTime.now());
    _focusedDay = DateTime.now();
  }


  @override
  void initState() {
    super.initState();
    List<DateTime> complateDtList = [
      DateTime(2022, 11, 1),
      DateTime(2022, 11, 2),
      DateTime(2022, 11, 3),
      DateTime(2022, 11, 4),
    ];
    _completeDays.addAll(complateDtList);

    List<DateTime> incomplateDtList = [
      DateTime(2022, 11, 7),
      DateTime(2022, 11, 8),
    ];
    _incompleteDays.addAll(incomplateDtList);
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
            AppRoutes.push(context, AppRoutes.timeSheetPage);
          },
          icon: const Icon(Icons.arrow_back)),
      child: TableCalendarWidget(_focusedDay, _completeDays, _incompleteDays,
              onDaySelected: onDaySelected, onTodayButtonTap: onTodayButtonTap)
          .build(),
    ).create();
  }
}
