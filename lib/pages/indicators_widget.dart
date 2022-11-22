// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../model/data_model.dart';

class IndicatorsWidget extends StatefulWidget {
  final List<TimeSlotStatModel> top5Map;
  final List<Color> colorList;

  const IndicatorsWidget({super.key, required this.top5Map, required this.colorList});

  @override
  State<IndicatorsWidget> createState() => _IndicatorsWidgetState();
}

class _IndicatorsWidgetState extends State<IndicatorsWidget> {
  @override
  Widget build(BuildContext context) {
    int idx = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.top5Map
          .asMap()
          .map((key, value) {
            return MapEntry(
                key,
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: buildIndicator(
                      widget.colorList[idx++], DataManager.findProjectName(value.project)),
                ));
          })
          .values
          .toList(),
    );
  }

  Widget buildIndicator(Color color, String title) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        SizedBox(
          width: 200,
          child: Text(
            title,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }
}
