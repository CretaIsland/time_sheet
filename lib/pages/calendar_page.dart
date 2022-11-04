import 'package:flutter/material.dart';

import '../common/creta_scaffold.dart';
import '../routes.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
      child: const Center(
        child: Text("Calendar pages"),
      ),
    ).create();
  }
}
