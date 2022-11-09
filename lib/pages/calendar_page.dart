import 'package:flutter/material.dart';

import '../common/creta_scaffold.dart';
//import '../common/table_calendar.dart';
import '../routes.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  //Set<DateTime> _selectedDays = {};
  //DateTime _focusedDay = DateTime.now();
  late PageController pageController;

  // void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  //   setState(() {
  //     if (_selectedDays.contains(selectedDay)) {
  //       _selectedDays.remove(selectedDay);
  //     } else {
  //       _selectedDays.add(selectedDay);
  //     }

  //     // _focusedDay = focusedDay;
  //     //
  //     // _focusedDay.value = focusedDay;
  //     // _rangeStart = null;
  //     // _rangeEnd = null;
  //     // _rangeSelectionMode = RangeSelectionMode.toggledOff;
  //   });
  // }

  // void onTodayButtonTap() {
  //   //setState(() => _focusedDay = DateTime.now());
  //   _focusedDay = DateTime.now();
  // }

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
      child: const Text('Calendar'), //TableCalendarWidget(_selectedDays, _focusedDay,
      //onDaySelected: onDaySelected, onTodayButtonTap: onTodayButtonTap)
      //.build(),
    ).create();
  }
}
