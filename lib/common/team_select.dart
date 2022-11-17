// ignore_for_file: prefer_const_constructors

import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:dropdown_pro/dropdown.dart';
import 'package:dropdown_pro/dropdown_item.dart';
import 'package:flutter/material.dart';

import '../model/data_model.dart';
import 'logger.dart';

class TeamSelectWidget extends StatefulWidget {
  final DropdownEditingController<String> controller;
  const TeamSelectWidget({super.key, required this.controller});

  @override
  State<TeamSelectWidget> createState() => _TeamSelectWidgetState();
}

class _TeamSelectWidgetState extends State<TeamSelectWidget> {
  String? _searchTeam;
  //final DropdownEditingController<String> _controller = DropdownEditingController<String>();

  @override
  void initState() {
    super.initState();
    _searchTeam = DataManager.projectOthers.keys.first;
    logger.finest('team=$_searchTeam');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _searchMyProject(),
        Divider(
          height: 10,
        ),
        DropdownButton<String>(
          value: _searchTeam,
          icon: Icon(Icons.arrow_downward),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              _searchTeam = value!;
            });
          },
          items: DataManager.projectOthers.keys.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.length > 6 ? value.substring(5) : value),
            );
          }).toList(),
        ),
        const SizedBox(
          height: 10,
        ),
        _searchTeamProject(_searchTeam!),
      ],
    );
  }

  Widget _searchMyProject() {
    List<DropdownItem> list = [];
    for (String element in DataManager.projectDescList) {
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

  Widget _searchTeamProject(String tmId) {
    if (DataManager.projectOthers[tmId] == null) {
      return Text('$tmId is null');
    }

    List<DropdownItem> list = [];
    for (String element in DataManager.projectOthers[tmId]!) {
      String id = element.substring(0, element.indexOf('/'));
      list.add(DropdownItem(id: id, value: element));
    }
    return Dropdown.singleSelection(
        title: tmId.length > 6 ? tmId.substring(5) : tmId,
        labelText: "타부서 프로젝트 선택",
        hintText: "타부서 프로젝트 선택",
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
