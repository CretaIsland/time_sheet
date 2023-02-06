import 'package:flutter/material.dart';
import 'package:simple_tags/simple_tags.dart';

import '../common/logger.dart';
import '../model/data_model.dart';
import 'day_time_sheet_data_manager.dart';

class DayTimeSheetPage extends StatefulWidget {
  const DayTimeSheetPage({super.key});

  @override
  State<DayTimeSheetPage> createState() => _DayTimeSheetPageState();
}

class _DayTimeSheetPageState extends State<DayTimeSheetPage> {
  
  List<String> weekDayString = ["일", "월", "화", "수", "목", "금", "토"];
  List<String> timeSheetData = List<String>.filled(24, "");
  bool isShowChoiceBox = false;
  bool isLoadding = true;
  int timeSlotIndex = 0;

  DayTimeSheetDataManager? dayTimeSheetDataManager;

  @override
  void initState() {
    super.initState();
    dayTimeSheetDataManager = DayTimeSheetDataManager();  
    dayTimeSheetDataManager!.openDB().then((value) {  // open database
      dayTimeSheetDataManager!.checkDate(DataManager.formatter.format(DateTime.now())).then((value) { // 날짜가 변경되었는지 확인
        dayTimeSheetDataManager!.getTimeSheetData().then((value) {  // 타임시트 데이터 가져오기
          setState(() {
            timeSheetData = value;
            isLoadding = false;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.finest("build");
    return Material(
      child: GestureDetector(
        onTap: () {
          if(isShowChoiceBox) {
            setState(() {
              isShowChoiceBox = false;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.2),
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.4),
                Colors.blue.withOpacity(0.5),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            )
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .04,
                    child: Text(
                      '${DataManager.formatter.format(DateTime.now())}(${weekDayString[DateTime.now().weekday]})', 
                      style: const TextStyle(color: Colors.black, fontSize: 26)
                    ),
                  ),
                  isLoadding ? Container() : 
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .88,
                    child: ListView.builder(
                      itemCount: 24,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(index<10 ? '0$index' : '$index', style: const TextStyle(fontSize: 24)),
                            GestureDetector(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                width: timeSheetData[index].isEmpty ? MediaQuery.of(context).size.width * .8 : MediaQuery.of(context).size.width * .6,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                    Colors.white,
                                    Colors.blue.withOpacity(0.3),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                ),
                                child: Center(
                                  child: Text(
                                    timeSheetData[index],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 20
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  timeSlotIndex = index;
                                  isShowChoiceBox = !isShowChoiceBox;
                                });
                              },
                            ),
                            timeSheetData[index].isNotEmpty ? GestureDetector(
                              onTap: () {
                                // 삭제
                                setState(() {
                                  timeSheetData[index] = "";
                                  dayTimeSheetDataManager!.deleteTimeSheetData(index);
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                width: MediaQuery.of(context).size.width * .17,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.4),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                ),
                                child: const Center(
                                  child: Text("X",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 20
                                    ),
                                  ),
                                ),
                              ),
                            ) : const SizedBox(width: 0)
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              Center(
                child: choiceBox(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget choiceBox() {
    return Visibility(
      visible: isShowChoiceBox,
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: SimpleTags(
                content: const ["업무", "공부", "취미", "휴식", "식사", "취침"],
                wrapSpacing: 4,
                wrapRunSpacing: 4,
                tagContainerPadding: const EdgeInsets.all(6),
                tagTextStyle: const TextStyle(color: Colors.blue, fontSize: 16),
                tagContainerDecoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(139, 139, 142, 0.16),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1.75, 3.5), // c
                    )
                  ],
                ),
                onTagPress: (String tagValue) {
                  setState(() {
                    isShowChoiceBox = false;
                    timeSheetData[timeSlotIndex] = tagValue;
                    dayTimeSheetDataManager!.addTimeSheetData(timeSlotIndex, tagValue);
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isShowChoiceBox = false;
                });
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            ),
          ],
        ),
      )
    );
  }
}