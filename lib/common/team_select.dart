// ignore_for_file: prefer_const_constructors

import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';

import '../model/data_model.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 5,
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

  Widget _searchTeamProject(String tmId) {
    if (DataManager.projectOthers[tmId] == null) {
      return Text('$tmId is null');
    }
    return TextDropdownFormField(
      controller: widget.controller,
      options: DataManager.projectOthers[tmId]!,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down),
          labelText: "타 부서 프로젝트 선택"),
      dropdownHeight: 240,
    );
  }
}
