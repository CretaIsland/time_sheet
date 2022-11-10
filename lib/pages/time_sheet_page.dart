// ignore_for_file: prefer_const_constructors, avoid_print, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../common/creta_scaffold.dart';
import '../common/logger.dart';
import '../model/data_model.dart';
import '../routes.dart';
import 'time_slot_item.dart';

class TimeSheetPage extends StatefulWidget {
  const TimeSheetPage({super.key});

  static List<String> favorateList = [];
  static List<String> projectList = [
    "AAAA",
    "BAAA",
    "CAAA",
    "DAAA",
    "EAAA",
    "FRRR",
    "GHHH",
    "HEEE",
    "XXXX",
    "ZZZZ",
    "KKKK",
    "LLLL",
    "ZZZ1",
    "1234",
    "3456",
  ];

  @override
  State<TimeSheetPage> createState() => _TimeSheetPageState();
}

class _TimeSheetPageState extends State<TimeSheetPage> {
  int _dateMove = 0;
  bool _moveToRight = false;
  //String? _today;
  String? _weekday;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getToday();
    return CretaScaffold(
      gotoToday: () {
        setState(() {
          _dateMove = 0;
        });
      },
      title: 'Its time to do something crazy',
      context: context,
      actions: [
        IconButton(
            onPressed: () {
              AppRoutes.push(context, AppRoutes.settingPage);
            },
            icon: Icon(Icons.settings))
      ],
      leading: IconButton(
          onPressed: () {
            //AppRoutes.pop(context);
            AppRoutes.push(context, AppRoutes.login);
          },
          icon: Icon(Icons.arrow_back)),
      child: _mainPage(),
    ).create();
  }

  Widget _mainPage() {
    return FutureBuilder<List<TimeSlotModel>>(
        future: _getTimeSheetData(),
        builder: (context, AsyncSnapshot<List<TimeSlotModel>> snapshot) {
          if (snapshot.hasError) {
            //error가 발생하게 될 경우 반환하게 되는 부분
            logger.severe("data fetch error");
            return const Center(child: Text('data fetch error'));
          }
          if (snapshot.hasData == false) {
            logger.severe("No data founded");
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            logger.finest("book founded ${snapshot.data!.length}");
            // if (snapshot.data!.isEmpty) {
            //   return const Center(child: Text('no book founded'));
            // }
            return _drawPage();
          }
          return Container();
        });
  }

  Future<List<TimeSlotModel>> _getTimeSheetData() async {
    logger.finest('_getTimeSheetData(${DataManager.showDate})');
    _createSample();
    return sampleList;
  }

  Widget _drawPage() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            alignment: AlignmentDirectional.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: _toPast,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 32,
                    )),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _dateMove = 0;
                    });
                  },
                  child: Text(
                    '${DataManager.showDate}$_weekday',
                    style: TextStyle(
                      fontSize: 24,
                      color: _dateMove == 0 ? Colors.black : Colors.blue[500]!,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: _toFuture,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 32,
                    )),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 11,
          child: GestureDetector(
            onPanUpdate: (details) {
              // Swiping in right direction.
              if (details.delta.dx > 0) {
                _toPast();
              }
              // Swiping in left direction.
              if (details.delta.dx < 0) {
                _toFuture();
              }
            },
            child: WidgetAnimator(
              incomingEffect: _moveToRight
                  ? WidgetTransitionEffects.incomingScaleUp(
                      rotation: 0.2,
                      curve: Curves.easeInQuad,
                    )
                  : WidgetTransitionEffects.incomingScaleUp(
                      rotation: -0.2,
                      curve: Curves.easeInQuad,
                    ),
              // WidgetTransitionEffects.incomingSlideInFromRight(
              //     curve: Curves.easeInQuad, scale: 0.6)
              // : WidgetTransitionEffects.incomingSlideInFromLeft(
              //     curve: Curves.easeInQuad, scale: 0.6),
              child: _timeSheetView(),
            ),
          ),
        ),
      ],
    );
  }

  void _toPast() {
    setState(() {
      _dateMove--;
      _moveToRight = true;
      print('left to right $_dateMove');
    });
  }

  void _toFuture() {
    setState(() {
      _dateMove++;
      _moveToRight = false;
      print('right to left $_dateMove');
    });
  }

  List<TimeSlotModel> sampleList = [];

  void _createSample() {
    sampleList.add(TimeSlotModel(timeSlot: '07', projectCode2: 'BBBB'));
    sampleList.add(TimeSlotModel(timeSlot: '08', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '09'));
    sampleList.add(TimeSlotModel(timeSlot: '10', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '11', projectCode1: 'AAAA', projectCode2: 'BBBB'));
    sampleList.add(TimeSlotModel(timeSlot: '12', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '13', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '14', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '15', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '16', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '17', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '18', projectCode1: 'AAAA', projectCode2: 'BBBB'));
    sampleList.add(TimeSlotModel(timeSlot: '19', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '20', projectCode1: 'AAAA'));
    sampleList.add(TimeSlotModel(timeSlot: '21', projectCode2: 'BBBB'));
    sampleList.add(TimeSlotModel(timeSlot: '*'));
  }

  Widget _timeSheetView() {
    //_createSample();
    return ListView.builder(
      shrinkWrap: true,
      //initialItemCount: 15,
      itemCount: 16,
      itemBuilder: (
        context,
        index,
        /*animation*/
      ) {
        return TimeSlotItem(
          item: sampleList[index],
          //animation: animation,
          onPaint: () {
            bool changed = false;
            for (int i = index + 1; i < sampleList.length; i++) {
              if (sampleList[i].timeSlot == '12') {
                continue;
              }
              if (sampleList[i].projectCode1 != null) {
                break;
              }
              if (sampleList[i].projectCode2 != null) {
                break;
              }
              String? project1 = sampleList[index].projectCode1;
              String? project2 = sampleList[index].projectCode2;
              if (project1 != null) {
                sampleList[i].projectCode1 = project1;
                changed = true;
              }
              if (project2 != null) {
                sampleList[i].projectCode2 = project2;
                changed = true;
              }
            }
            if (changed) {
              setState(() {});
            }
          },
        );
      },
    );
  }

  // List<Widget> _timeSheetView() {
  //   _createSample();
  //   return List.generate(15, (index) {
  //     return TimeSlotItem(
  //       item: sampleList[index],
  //       //animation: animation,
  //       onDelete: () {},
  //       onSplit: () {},
  //       onPaint: () {},
  //       onSaveClicked: () {},
  //     );
  //   });
  // }

  void _getToday() {
    DateTime now = DateTime.now();
    if (_dateMove > 0) {
      now = now.add(Duration(days: _dateMove));
    }
    if (_dateMove < 0) {
      now = now.subtract(Duration(days: -1 * _dateMove));
    }
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    DataManager.showDate = formatter.format(now);
    String weekTemp = DateFormat('EEEE').format(now);
    switch (weekTemp) {
      case 'Monday':
        weekTemp = '월';
        break;
      case 'Tuesday':
        weekTemp = '화';
        break;
      case 'Wednesday':
        weekTemp = '수';
        break;
      case 'Thursday':
        weekTemp = '목';
        break;
      case 'Friday':
        weekTemp = '금';
        break;
      case 'Saturday':
        weekTemp = '토';
        break;
      case 'Sunday':
        weekTemp = '일';
        break;
    }
    _weekday = '($weekTemp)';
  }
}
