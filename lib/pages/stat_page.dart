// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../common/creta_scaffold.dart';
import '../common/logger.dart';
import '../model/data_model.dart';
import '../routes.dart';
import 'indicators_widget.dart';

class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  final List<Color> _colorList = [
    Colors.red.withOpacity(0.5),
    Colors.blue.withOpacity(0.5),
    Colors.green.withOpacity(0.5),
    Colors.purple.withOpacity(0.5),
    Colors.amber.withOpacity(0.5),
    Colors.grey.withOpacity(0.5),
  ];

  List<TimeSlotStatModel> top5Map = [];

  @override
  Widget build(BuildContext context) {
    return CretaScaffold(
      title: '통계 보기',
      context: context,
      leading: IconButton(
          onPressed: () {
            //AppRoutes.pop(context);
            AppRoutes.push(context, AppRoutes.statPage, AppRoutes.timeSheetPage);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.blue,
          )),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.circle,
              color: Colors.transparent,
            )),
      ],
      child: _showStat(context),
    ).create();
  }

  Widget _showStat(BuildContext context) {
    return FutureBuilder<List<TimeSlotStatModel>?>(
        future: DataManager.getTimeSheetStat(),
        //future: DataManager.getTimeSheetStatSimulation(context),
        builder: (context, AsyncSnapshot<List<TimeSlotStatModel>?> snapshot) {
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

  List<PieChartSectionData> getSections() {
    int idx = 0;
    return top5Map
        .asMap()
        .map((key, data) {
          final value = PieChartSectionData(
            color: _colorList[idx++],
            value: data.sum,
            title: '${data.sum.round()}%',
            titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          );
          return MapEntry(key, value);
        })
        .values
        .toList();
  }

  Widget _drawPage(List<TimeSlotStatModel> dataList) {
    double total = 0;
    double other = 0;

    for (var element in dataList) {
      total += element.sum;
    }
    for (int idx = 0; idx < dataList.length; idx++) {
      if (idx < 5) {
        top5Map.add(TimeSlotStatModel(dataList[idx].project, (dataList[idx].sum / total) * 100));
      } else {
        other += dataList[idx].sum;
      }
    }
    if (dataList.length > 5) {
      top5Map.add(TimeSlotStatModel('Others', (other / total) * 100));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('사업부 프로젝트별 투입비율(1.1~현재)'),
          Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.amber,
          ),
          Container(
            color: Colors.black12,
            width: 250,
            height: 250,
            child: PieChart(
              PieChartData(
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: getSections(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: IndicatorsWidget(
                  top5Map: top5Map,
                  colorList: _colorList,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
