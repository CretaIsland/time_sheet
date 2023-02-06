import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart';

class DayTimeSheetPage extends StatefulWidget {
  const DayTimeSheetPage({super.key});

  @override
  State<DayTimeSheetPage> createState() => _DayTimeSheetPageState();
}

class _DayTimeSheetPageState extends State<DayTimeSheetPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("일일 타임시트", style: TextStyle(color: Colors.white)),
    );
  }
}