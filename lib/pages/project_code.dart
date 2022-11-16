import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:simple_tags/simple_tags.dart';

import '../common/logger.dart';
import '../common/team_select.dart';
import '../model/data_model.dart';

class ProjectCodeWidget extends StatefulWidget {
  final void Function(String tag) onFavorite;
  final void Function(String? tag) onOK;
  final void Function() onCancel;
  const ProjectCodeWidget(
      {super.key, required this.onFavorite, required this.onOK, required this.onCancel});

  @override
  State<ProjectCodeWidget> createState() => _ProjectCodeWidgetState();
}

class _ProjectCodeWidgetState extends State<ProjectCodeWidget> {
  final DropdownEditingController<String> _controller = DropdownEditingController<String>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('프로젝트 코드를 선택하세요'),
        _favorateProject(),
        _searchProject(),
        const SizedBox(height: 20),
        TeamSelectWidget(controller: _controller),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                widget.onCancel.call();
                Navigator.of(context).pop(true);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onOK(_controller.value);
                Navigator.of(context).pop(true);
              },
              child: const Text("OK"),
            ),
          ],
        )
      ],
    );
  }

  Widget _favorateProject() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SimpleTags(
        content: DataManager.myFavoriteList,
        wrapSpacing: 4,
        wrapRunSpacing: 4,
        onTagPress: (tag) {
          logger.finest('pressed $tag');
          widget.onFavorite(tag);
          Navigator.of(context).pop(true);
        },
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

  Widget _searchProject() {
    return TextDropdownFormField(
      controller: _controller,
      options: DataManager.projectDescList,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down),
          labelText: "내 부서 프로젝트 선택"),
      dropdownHeight: 240,
    );
  }
}
