// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../common/creta_scaffold.dart';
import '../routes.dart';
import 'time_slot_item.dart';

class TimeSheetPage extends StatefulWidget {
  const TimeSheetPage({super.key});

  @override
  State<TimeSheetPage> createState() => _TimeSheetPageState();
}

class _TimeSheetPageState extends State<TimeSheetPage> {
  int _dateMove = 0;
  bool _moveToRight = false;
  @override
  Widget build(BuildContext context) {
    String today = _getToday();
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
      child: Column(
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
                      today,
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
                  _toFuture();
                }
                // Swiping in left direction.
                if (details.delta.dx < 0) {
                  _toPast();
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
      ),
    ).create();
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
  }

  Widget _timeSheetView() {
    _createSample();
    return ListView.builder(
      shrinkWrap: true,
      //initialItemCount: 15,
      itemCount: 15,
      itemBuilder: (
        context,
        index,
        /*animation*/
      ) {
        return TimeSlotItem(
          item: sampleList[index],
          //animation: animation,
          onDelete: () {},
          onSplit: () {},
          onPaint: () {},
          onSaveClicked: () {},
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

  String _getToday() {
    DateTime now = DateTime.now();
    if (_dateMove > 0) {
      now = now.add(Duration(days: _dateMove));
    }
    if (_dateMove < 0) {
      now = now.subtract(Duration(days: -1 * _dateMove));
    }
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String strToday = formatter.format(now);
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
    return '$strToday($weekTemp)';
  }
}
