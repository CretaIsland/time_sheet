// ignore_for_file: prefer_const_constructors

import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:simple_tags/simple_tags.dart';
import 'package:time_sheet/pages/time_slot_item.dart';

import '../common/logger.dart';
import '../common/team_select.dart';
import '../model/data_model.dart';
import 'time_sheet_wrapper.dart';

class ProjectChoice extends StatefulWidget {
  static TimeSlotModel? selectedModel;
  static TimeSlotType? selectedTtype;

  const ProjectChoice({super.key});

  @override
  State<ProjectChoice> createState() => _ProjectChoiceState();
}

class _ProjectChoiceState extends State<ProjectChoice> {
  final DropdownEditingController<String> _controller = DropdownEditingController<String>();
  String? _justSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: TimeSheetWrapper.drawerWidth,
        //height: 600,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text('프로젝트 코드를 선택하세요'),
            _favorateProject(),
            //_searchProject(),
            SizedBox(height: 20),
            TeamSelectWidget(controller: _controller),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DialogButton(
                  width: 100,
                  onPressed: onCancel,
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                DialogButton(
                  width: 100,
                  color: Colors.amber,
                  onPressed: () {
                    onOK(_controller.value, ProjectChoice.selectedTtype!);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void onOK(String? tag, TimeSlotType ttype) async {
    if (tag == null) {
      _justSelected = null;
      return;
    }
    String temp = tag;
    int idx = temp.indexOf('/');
    _justSelected = temp.substring(0, idx);
    if (DataManager.myFavoriteList.isEmpty || DataManager.myFavoriteList.first != _justSelected!) {
      if (DataManager.myFavoriteList.contains(_justSelected!)) {
        DataManager.myFavoriteList.remove(_justSelected!);
      }
      DataManager.myFavoriteList.insert(0, _justSelected!);
      if (DataManager.myFavoriteList.length >= 10) {
        DataManager.myFavoriteList.removeAt(DataManager.myFavoriteList.length - 1);
      }
    }
    await _saveJob();
    _controller.value = null;
    // ignore: use_build_context_synchronously
    _close();
  }

  void _close() {
    tsGlobalKey.currentState?.closeDrawer();
    //AppRoutes.push(context, AppRoutes.timeSheetPage);
  }

  void onCancel() {
    _justSelected = null;
    _close();
  }

  Widget _favorateProject() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SimpleTags(
        content: DataManager.myFavoriteList,
        wrapSpacing: 4,
        wrapRunSpacing: 4,
        onTagPress: onFavorite,

        // onTagLongPress: (tag) {
        //   logger.finest('long pressed $tag');
        // },
        // onTagDoubleTap: (tag) {
        //   logger.finest('double tapped $tag');
        // },
        tagContainerPadding: const EdgeInsets.all(6),
        tagTextStyle: const TextStyle(color: Colors.blue, fontSize: 16),
        // tagIcon: IconButton(
        //   icon: const Icon(Icons.clear),
        //   iconSize: 12,
        //   onPressed: () {},
        // ),
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
    );
  }

  // Widget _searchProject() {
  //   return TextDropdownFormField(
  //     controller: _controller,
  //     options: DataManager.projectDescList,
  //     decoration: const InputDecoration(
  //         border: OutlineInputBorder(),
  //         suffixIcon: Icon(Icons.arrow_drop_down),
  //         labelText: "내 부서 프로젝트 선택"),
  //     dropdownHeight: 240,
  //   );
  // }

  void onFavorite(String tag) async {
    logger.finest('pressed $tag');
    _justSelected = tag;
    await _saveJob();
    // ignore: use_build_context_synchronously
    _close();
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
}
