// ignore_for_file: prefer_const_constructors

import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:dropdown_pro/dropdown.dart';
import 'package:dropdown_pro/dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_sheet/model/project_list_manager.dart';

import '../model/data_model.dart';
import 'logger.dart';

class TeamSelectWidget extends StatefulWidget {
  final DropdownEditingController<String> controller;
  const TeamSelectWidget({super.key, required this.controller});

  @override
  State<TeamSelectWidget> createState() => _TeamSelectWidgetState();
}

class _TeamSelectWidgetState extends State<TeamSelectWidget> {
  //final DropdownEditingController<String> _controller = DropdownEditingController<String>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ ChangeNotifierProvider<ProjectDataManager>.value(value: projectDataHolder! ) ],
      child: Consumer<ProjectDataManager>(
        builder: (context, projectDataManager, child) {
          return Column(
            children: [
              _searchMyProject(),
              Divider(
                height: 10,
              ),
              DropdownButton<String>(
                value: projectDataManager.selectTeamId,
                icon: Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  projectDataManager.selectTeam(value!);
                },
                items: projectDataManager.projectOthers.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.length > 6 ? value.substring(5) : value),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 10,
              ),
              _searchTeamProject(),
            ],
          );
        },
      ),
    );
  }

  Widget _searchMyProject() {
    List<DropdownItem> list = [];
    for (String element in projectDataHolder!.projectDescList) {
      String id = element.substring(0, element.indexOf('/'));
      list.add(DropdownItem(id: id, value: element));
    }
    return Dropdown.singleSelection(
        title: "내부서 프로젝트 선택",
        labelText: "내부서 프로젝트 선택",
        hintText: "내부서 프로젝트 선택",
        list: list,
        selectedId: '',
        isAddItem: false,
        onSingleItemListener: (selectedItem) {
          widget.controller.value = selectedItem.value;
        });

    // return TextDropdownFormField(
    //   controller: _controller,
    //   options: DataManager.projectDescList,
    //   decoration: const InputDecoration(
    //       border: OutlineInputBorder(),
    //       suffixIcon: Icon(Icons.arrow_drop_down),
    //       labelText: "내 부서 프로젝트 선택"),
    //   dropdownHeight: 240,
    // );
  }

  Widget _searchTeamProject() {
    if (projectDataHolder!.projectOthers[projectDataHolder!.selectTeamId] == null) {
      return Text('$projectDataHolder!.selectTeamId is null');
    }

    List<DropdownItem> list = [];
    for (String element in projectDataHolder!.projectOthers[projectDataHolder!.selectTeamId]!) {
      String id = element.substring(0, element.indexOf('/'));
      list.add(DropdownItem(id: id, value: element));
    }
    return Dropdown.singleSelection(
        title: projectDataHolder!.selectTeamId!.length > 6 ? projectDataHolder!.selectTeamId!.substring(5) : projectDataHolder!.selectTeamId!,
        labelText: "타부서 프로젝트 선택",
        hintText: projectDataHolder!.selectTeamId != null ? "${projectDataHolder!.selectTeamId!.substring(5)} 선택" : "타부서 프로젝트 선택",
        list: list,
        selectedId: '',
        isAddItem: false,
        onSingleItemListener: (selectedItem) {
          widget.controller.value = selectedItem.value;
        });
    // return TextDropdownFormField(
    //   controller: widget.controller,
    //   options: DataManager.projectOthers[tmId]!,
    //   decoration: const InputDecoration(
    //       border: OutlineInputBorder(),
    //       suffixIcon: Icon(Icons.arrow_drop_down),
    //       labelText: "타 부서 프로젝트 선택"),
    //   dropdownHeight: 240,
    // );
  }
}
