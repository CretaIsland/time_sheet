// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:simple_tags/simple_tags.dart';

import '../api/api_service.dart';
import '../common/creta_scaffold.dart';
import '../common/logger.dart';
import '../model/data_model.dart';
import '../routes.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _tagPressed = false;

  @override
  Widget build(BuildContext context) {
    return CretaScaffold(
      title: '당신이 잃어버린 시간      ',
      context: context,
      //actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings))],
      leading: IconButton(
          onPressed: () {
            //AppRoutes.pop(context);
            AppRoutes.lastPage = AppRoutes.settingPage;
            AppRoutes.push(context, AppRoutes.timeSheetPage);
          },
          icon: const Icon(Icons.arrow_back)),
      child: Center(
        child: AppRoutes.lastPage == AppRoutes.timeSheetPage
            ? futureAlarmList(context)
            : _showAlarmList(context),
      ),
    ).create();
  }

  Widget futureAlarmList(BuildContext context) {
    return FutureBuilder<String>(
        future: _getAlarmList(context),
        builder: (context, AsyncSnapshot<String> snapshot) {
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
            logger.finest("data founded ${snapshot.data!}");
            return _showAlarmList(context);
          }
          return _showAlarmList(context);
        });
  }

  Future<String> _getAlarmList(BuildContext context) async {
    if (DataManager.loginUser == null || DataManager.loginUser!.sabun == null) {
      return "Unknown User";
    }
    dynamic alarmResult = await ApiService.getAlarmRecord(DataManager.loginUser!.sabun!)
        .catchError((error, stackTrace) {
      return "API Communication Error";
    });
    Map<String, dynamic> alarmData =
        Map<String, dynamic>.from(alarmResult); //jsonDecode(alarmResult);
    String alarmErrMsg = alarmData['err_msg'] ?? '';
    if (alarmErrMsg.compareTo('succeed') != 0 || alarmData['data'] == null) {
      // something error
      return alarmErrMsg;
    }
    List<AlarmModel> alarmModelList = [];
    List<dynamic> dataList = alarmData['data']; //jsonDecode(alarmData['data']);
    //int alarmCount = loginData['count'] ?? 0;
    for (var ele in dataList) {
      Map<String, dynamic> alarm = Map<String, dynamic>.from(ele); //jsonDecode(ele);
      String alarmDate = alarm['date'] ?? '';
      if (alarmDate.isEmpty) continue;
      if (alarm['list'] == null) continue;
      List<dynamic> timeList = List<dynamic>.from(alarm['list']!);
      for (var eleTime in timeList) {
        AlarmModel alarm = AlarmModel(date: alarmDate, timeSlot: eleTime);
        alarmModelList.add(alarm);
      }
    }
    DataManager.alarmList = alarmModelList;
    return "succeed";
  }

  Widget _showAlarmList(BuildContext context) {
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-01", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-02", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-03", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-04", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-05", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-06", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-07", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-08", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-09", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-10", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-11", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-12", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-13", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-14", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-15", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-16", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-17", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-18", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-19", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-20", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-21", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-22", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-22", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-22", timeSlot: ''));
    // DataManager.alarmList.add(AlarmModel(date: "2022-10-23", timeSlot: ''));

    List<Set<String>> dateSetList = [];
    Set<String> aDateSet = {};
    //Set<String> remainSet = {};
    for (AlarmModel element in DataManager.alarmList) {
      if (aDateSet.length < 21) {
        aDateSet.add(element.date);
      } else {
        Set<String> newSet = {};
        newSet.addAll(aDateSet);
        dateSetList.add(newSet);
        aDateSet.clear();
        //remainSet.add(element.date);
      }
    }
    if (aDateSet.isNotEmpty) {
      dateSetList.add(aDateSet);
    }

    int total = 0;
    for (var element in dateSetList) {
      total += element.length;
    }

    return SafeArea(
      child: Container(
        color: Colors.blue.withOpacity(0.2),
        width: double.infinity,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '$total개의 작성하지 않은 타임시트가 있습니다.\n해당 날짜를 태그하여 타임시트를 작성해 주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: Text(
                  '무시하고 그냥 오늘 날짜 보기',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  DataManager.showDate = DataManager.getTodayString();
                  AppRoutes.lastPage = AppRoutes.settingPage;
                  Routemaster.of(context).push(AppRoutes.timeSheetPage);
                },
              ),
            ),
            Scrollbar(
              thumbVisibility: true,
              child: SizedBox(
                height: 400,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dateSetList.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return Center(
                        child: SimpleTags(
                          content: dateSetList[index].toList(),
                          wrapSpacing: 4,
                          wrapRunSpacing: 4,
                          onTagPress: (tag) {
                            setState(() {
                              _tagPressed = true;
                            });
                            logger.finest('pressed $tag');
                            DataManager.showDate = tag;
                            AppRoutes.lastPage = AppRoutes.settingPage;
                            Routemaster.of(context).push(AppRoutes.timeSheetPage);
                          },
                          tagContainerPadding: const EdgeInsets.all(10),
                          tagTextStyle: const TextStyle(color: Colors.blue, fontSize: 16),
                          tagContainerDecoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(139, 139, 142, 0.16),
                                spreadRadius: _tagPressed ? 4 : 1,
                                blurRadius: _tagPressed ? 4 : 1,
                                offset: _tagPressed ? Offset(1.75, 3.5) : Offset(1, 2),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),

            // Scrollbar(
            //   thumbVisibility: true,
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 12.0),
            //     child: SimpleTags(
            //       content: dateSet.toList(),
            //       wrapSpacing: 4,
            //       wrapRunSpacing: 4,
            //       onTagPress: (tag) {
            //         setState(() {
            //           _tagPressed = true;
            //         });
            //         logger.finest('pressed $tag');
            //         DataManager.showDate = tag;
            //         AppRoutes.lastPage = AppRoutes.settingPage;
            //         Routemaster.of(context).push(AppRoutes.timeSheetPage);
            //       },
            //       tagContainerPadding: const EdgeInsets.all(20),
            //       tagTextStyle: const TextStyle(color: Colors.blue, fontSize: 24),
            //       tagContainerDecoration: BoxDecoration(
            //         color: Colors.white,
            //         border: Border.all(color: Colors.grey),
            //         borderRadius: const BorderRadius.all(
            //           Radius.circular(20),
            //         ),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Color.fromRGBO(139, 139, 142, 0.16),
            //             spreadRadius: _tagPressed ? 4 : 1,
            //             blurRadius: _tagPressed ? 4 : 1,
            //             offset: _tagPressed ? Offset(1.75, 3.5) : Offset(1, 2),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // (total > dateSet.length)
            //     ? Padding(
            //         padding: EdgeInsets.all(8.0),
            //         child: Text(
            //           'And more ..',
            //           style: TextStyle(
            //             fontSize: 18,
            //           ),
            //         ),
            //       )
            //     : Container(),
          ],
        ),
      ),
    );
    //});
  }
}
