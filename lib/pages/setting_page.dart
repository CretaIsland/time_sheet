import 'package:flutter/material.dart';

import '../common/creta_scaffold.dart';
import '../routes.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return CretaScaffold(
      title: 'Setting pages',
      context: context,
      //actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings))],
      leading: IconButton(
          onPressed: () {
            //AppRoutes.pop(context);
            AppRoutes.push(context, AppRoutes.timeSheetPage);
          },
          icon: const Icon(Icons.arrow_back)),
      child: const Center(
        child: Text("Setting pages"),
      ),
    ).create();
  }
}
