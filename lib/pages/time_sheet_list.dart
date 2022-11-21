// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_tags/simple_tags.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:time_sheet/pages/project_choice.dart';
import 'package:time_sheet/pages/time_sheet_wrapper.dart';
import 'package:time_sheet/pages/time_slot_item.dart';

import '../common/logger.dart';
import '../model/data_model.dart';
import '../model/slot_manager.dart';

GlobalKey<TimeSheetListState> timeSheetListGlobalKey = GlobalKey<TimeSheetListState>();

class TimeSheetList extends StatefulWidget {
  final List<TimeSlotModel> dailyList;
  const TimeSheetList({super.key, required this.dailyList});

  @override
  State<TimeSheetList> createState() => TimeSheetListState();
}

class TimeSheetListState extends State<TimeSheetList> {
  String? _justSelected;
  bool _showMenu = false;

  void showMenu() {
    setState(() {
      _showMenu = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _timeSheetView(widget.dailyList);
  }

  Widget _timeSheetView(List<TimeSlotModel> dailyList) {
    //_createSample();
    ListView listView = ListView.builder(
      shrinkWrap: true,
      //initialItemCount: 15,
      itemCount: dailyList.length,
      itemBuilder: (
        context,
        index,
        /*animation*/
      ) {
        return Consumer<SlotManager>(builder: (context, slotManager, child) {
          logger.finest('_timeSheetView setState()');
          return TimeSlotItem(
            itemKey: GlobalKey<TimeSlotItemState>(),
            model: dailyList[index],
            //animation: animation,
            onCopy: () async {
              String? project1 = dailyList[index].projectCode1;
              String? project2 = dailyList[index].projectCode2;

              if (project1 != null && project2 == null) {
                project2 = project1;
                dailyList[index].projectCode2 = project1;
                dailyList[index].notifyUI =
                    await DataManager.saveTimeSheet(dailyList[index].timeSlot, project1, project2);
              }

              bool changed = false;
              for (int i = index + 1; i < dailyList.length; i++) {
                if (dailyList[i].timeSlot == '12') {
                  continue;
                }
                if (index < 12 && dailyList[i].timeSlot == '19') {
                  break; // 18시이후는 자동도배해주지 않는다.
                }
                if (dailyList[i].projectCode1 != null) {
                  break;
                }
                if (dailyList[i].projectCode2 != null) {
                  break;
                }

                if (project2 != null) {
                  dailyList[i].projectCode1 = project2;
                  dailyList[i].projectCode2 = project2;
                  changed = true;
                } else if (project1 != null) {
                  dailyList[index].projectCode2 = project1;
                  dailyList[i].projectCode1 = project1;
                  dailyList[i].projectCode2 = project1;
                  changed = true;
                }
                if (changed) {
                  dailyList[i].notifyUI = await DataManager.saveTimeSheet(dailyList[i].timeSlot,
                      dailyList[i].projectCode1 ?? '', dailyList[i].projectCode2 ?? '');
                }
              }
              if (changed) {
                slotManagerHolder!.notify();
              }
            },
          );
        });
      },
    );
    return Stack(
        alignment: AlignmentDirectional.center,
        children: [listView, _showMenu ? _favorateProject() : Container()]);
  }

  void onFavorite(String tag) async {
    logger.finest('pressed $tag');
    _justSelected = tag;
    _showMenu = false;
    await _saveJob();
    // ignore: use_build_context_synchronously
    //Navigator.pop(context);
  }

  Future<void> _saveJob() async {
    if (_justSelected != null && ProjectChoice.selectedTtype != TimeSlotType.none) {
      if (ProjectChoice.selectedTtype == TimeSlotType.after30) {
        ProjectChoice.selectedModel!.projectCode2 = _justSelected;
      } else if (ProjectChoice.selectedTtype == TimeSlotType.before30) {
        ProjectChoice.selectedModel!.projectCode1 = _justSelected;
      } else if (ProjectChoice.selectedTtype == TimeSlotType.wholeHour) {
        ProjectChoice.selectedModel!.projectCode1 = _justSelected;
        ProjectChoice.selectedModel!.projectCode2 = _justSelected;
      }
      ProjectChoice.selectedModel!.notifyUI = await DataManager.saveTimeSheet(
          ProjectChoice.selectedModel!.timeSlot,
          ProjectChoice.selectedModel!.projectCode1 ?? '',
          ProjectChoice.selectedModel!.projectCode2 ?? '');
      DataManager.saveAllMyFavorite();
      _justSelected = null;
      setState(() {});
    }
  }

  Widget _favorateProject() {
    return GlassContainer.frostedGlass(
      width: 300,
      height: 240,
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      borderWidth: 2,
      elevation: 5,
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SimpleTags(
            wrapAlignment: WrapAlignment.center,
            content: DataManager.myFavoriteList,
            wrapSpacing: 4,
            wrapRunSpacing: 4,
            onTagPress: onFavorite,
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
          ),
          Divider(
            color: Colors.white,
            indent: 20,
            endIndent: 20,
            thickness: 2.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    //Navigator.of(context).pop();
                    tsGlobalKey.currentState?.openDrawer();
                    setState(() {
                      _showMenu = false;
                    });
                  },
                  child: const Text(
                    "More...",
                    style: TextStyle(fontSize: 20, color: Colors.amber),
                  )),
              ElevatedButton(
                  onPressed: () {
                    //Navigator.of(context).pop();
                    setState(() {
                      _showMenu = false;
                    });
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
