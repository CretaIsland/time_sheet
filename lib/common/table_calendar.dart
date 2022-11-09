// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
//import 'package:flutter_speed_dial/flutter_speed_dial.dart';
//import '../../routes.dart';
//import 'logger.dart';
import 'dart:collection';
import 'utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TableCalendarWidget {
  late Function onTodayButtonTap;
  late Function onDaySelected;

  //late final ValueNotifier<List<Event>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  final Set<DateTime> _weekendDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  late PageController pageController;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  // RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  // DateTime? _rangeStart;
  // DateTime? _rangeEnd;

  TableCalendarWidget(
    DateTime focusedDay,
    Set<DateTime> selectedDays,
    Set<DateTime> weekendDays, {
    required this.onTodayButtonTap,
    required this.onDaySelected,
    //required this.pageController,
  }) {
    //_selectedDays.add(_focusedDay.value);
    //_selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    //_selectedDays.add(DateTime.now());
    _selectedDays.clear();
    for (var e in selectedDays) {
      _selectedDays.add(e);
    }
    _weekendDays.clear();
    for (var e in weekendDays) {
      _weekendDays.add(e);
    }
  }

  //bool get canClearSelection => _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  // List<Event> _getEventsForDay(DateTime day) {
  //   return kEvents[day] ?? [];
  // }
  //
  // List<Event> _getEventsForDays(Iterable<DateTime> days) {
  //   return [
  //     for (final d in days) ..._getEventsForDay(d),
  //   ];
  // }
  //
  // List<Event> _getEventsForRange(DateTime start, DateTime end) {
  //   final days = daysInRange(start, end);
  //   return _getEventsForDays(days);
  // }

  // void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  //   parent.setState(() {
  //     if (_selectedDays.contains(selectedDay)) {
  //       _selectedDays.remove(selectedDay);
  //     } else {
  //       _selectedDays.add(selectedDay);
  //     }
  //
  //     _focusedDay.value = focusedDay;
  //     _rangeStart = null;
  //     _rangeEnd = null;
  //     _rangeSelectionMode = RangeSelectionMode.toggledOff;
  //   });
  //
  //   _selectedEvents.value = _getEventsForDays(_selectedDays);
  // }

  // void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
  //   setState(() {
  //     _focusedDay.value = focusedDay;
  //     _rangeStart = start;
  //     _rangeEnd = end;
  //     _selectedDays.clear();
  //     _rangeSelectionMode = RangeSelectionMode.toggledOn;
  //   });
  //
  //   if (start != null && end != null) {
  //     _selectedEvents.value = _getEventsForRange(start, end);
  //   } else if (start != null) {
  //     _selectedEvents.value = _getEventsForDay(start);
  //   } else if (end != null) {
  //     _selectedEvents.value = _getEventsForDay(end);
  //   }
  // }

  Widget build() {
    return Column(
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (context, value, _) {
            return _CalendarHeader(
              focusedDay: value,
              clearButtonVisible: false, //canClearSelection,
              onTodayButtonTap: () => onTodayButtonTap(), //() { setState(() => _focusedDay.value = DateTime.now()); },
              // onClearButtonTap: () {
              //   setState(() {
              //     _rangeStart = null;
              //     _rangeEnd = null;
              //     _selectedDays.clear();
              //     _selectedEvents.value = [];
              //   });
              // },
              onLeftArrowTap: () {
                pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              onRightArrowTap: () {
                pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            );
          },
        ),
        TableCalendar<Event>(
          locale: 'ko_KR',
          daysOfWeekHeight: 30,
          rowHeight: 60,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(color: const Color(0xFF44FF44), shape: BoxShape.circle),
            weekendTextStyle: const TextStyle(color: Color(0xFFFF0000)),
            holidayDecoration: const BoxDecoration(
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFFFF4444), width: 1.4),
              ),
              shape: BoxShape.circle,
            ),
            //weekNumberTextStyle : const TextStyle(fontSize: 16, color: const Color(0xFF00FF00)),
            //outsideTextStyle: const TextStyle(color: Color(0xFF00FF00)),
            rowDecoration: const BoxDecoration(shape: BoxShape.circle),
          ),
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay.value,
          headerVisible: false,
          selectedDayPredicate: (day) => _selectedDays.contains(day),
          //rangeStartDay: _rangeStart,
          //rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          //rangeSelectionMode: _rangeSelectionMode,
          //eventLoader: _getEventsForDay,
          holidayPredicate: (day)=> _weekendDays.contains(day),
          // {
          //   // Every 20th day of the month will be treated as a holiday
          //   if (day.day % 7 == 1 || day.day % 7 == 2) return true;
          //   return day.day == 20;
          // },
          onDaySelected: (selectedDay, focusedDay) => onDaySelected(selectedDay, focusedDay), //_onDaySelected,
          //onRangeSelected: _onRangeSelected,
          onCalendarCreated: (controller) => pageController = controller,
          onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
          // onFormatChanged: (format) {
          //   if (_calendarFormat != format) {
          //     setState(() => _calendarFormat = format);
          //   }
          // },
        ),
      ],
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
//  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
//    required this.onClearButtonTap,
    required this.clearButtonVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM('ko_KR').format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          const Spacer(),
          SizedBox(
            width: 150.0,
            child: Text(
              headerText,
              style: TextStyle(fontSize: 26.0),
            ),
          ),
          // IconButton(
          //   icon: Icon(Icons.calendar_today, size: 20.0),
          //   visualDensity: VisualDensity.compact,
          //   onPressed: onTodayButtonTap,
          // ),
          const Spacer(),
          // if (clearButtonVisible)
          //   IconButton(
          //     icon: Icon(Icons.clear, size: 20.0),
          //     visualDensity: VisualDensity.compact,
          //     onPressed: onClearButtonTap,
          //   ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
          const SizedBox(width: 16.0),
        ],
      ),
    );
  }
}
