// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
//import 'package:material_dialogs/material_dialogs.dart';
//import 'package:material_dialogs/widgets/buttons/icon_button.dart';
//import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:simple_tags/simple_tags.dart';
import '../common/logger.dart';
import '../model/data_model.dart';
import 'time_sheet_page.dart';

class TimeSlotItem extends StatefulWidget {
  final TimeSlotModel item;
  //final Animation<double> animation;
  final VoidCallback onPaint;
  const TimeSlotItem({
    Key? key,
    required this.item,
    //required this.animation,
    required this.onPaint,
  }) : super(key: key);

  @override
  State<TimeSlotItem> createState() => _TimeSlotItemState();

  //List<String> favorateList = ["AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "XXXX"];

}

enum TimeSlotType {
  wholeHour,
  before30,
  after30,
  none,
}

class _TimeSlotItemState extends State<TimeSlotItem> {
  //static final Map<String, bool> _editModeMap = {};
  //final TextEditingController _controller = TextEditingController();
  final DropdownEditingController<String> _controller = DropdownEditingController<String>();
  String? _justSelected;
  @override
  Widget build(BuildContext context) {
    return
        //SizeTransition(
        //  key: ValueKey(widget.item.timeSlot),
        //  sizeFactor: widget.animation,
        // child:
        Container(
      margin: const EdgeInsets.all(4),

      //width: 800,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white30,
      ),
      child: ListTile(
        minVerticalPadding: 0,
        tileColor:
            widget.item.timeSlot == '12' || widget.item.timeSlot == '*' ? null : Colors.grey[300]!,
        dense: true,
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        visualDensity: VisualDensity.compact,
        leading:
            Text(widget.item.timeSlot, style: TextStyle(fontSize: 32, color: Colors.grey[500]!)),
        //title: (_editModeMap[widget.item.timeSlot] ?? false) ? _editTitle() : _getTitle(),
        title: _getTitle(),
        onTap: () {
          logger.finest('onTap');
          //_editModeMap.clear();
          //_editTitle();
        },
        // onLongPress: () {
        //   setState(() {
        //     _editModeMap.clear();
        //     _editModeMap[widget.item.timeSlot] = true;
        //   });
        // },
      ),
    );
    //);
  }

  void _editTitle(TimeSlotType ttype) async {
    logger.finest('_editTitle(${ttype.toString()}');

    bool? isOk = await Alert(
        context: context,
        title: "프로젝트 코드를 선택하세요",
        content: Column(
          children: <Widget>[
            _favorateProject(),
            _searchProject(),
          ],
        ),
        closeIcon: const Icon(Icons.close_outlined),
        buttons: [
          DialogButton(
            onPressed: () {
              _justSelected = null;
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            color: Colors.amber,
            onPressed: () {
              if (_controller.value != null) {
                _justSelected = _controller.value!;
                if (TimeSheetPage.favorateList.isEmpty ||
                    TimeSheetPage.favorateList.first != _justSelected!) {
                  if (TimeSheetPage.favorateList.contains(_justSelected!)) {
                    TimeSheetPage.favorateList.remove(_justSelected!);
                  }
                  TimeSheetPage.favorateList.insert(0, _justSelected!);
                  if (TimeSheetPage.favorateList.length >= 10) {
                    TimeSheetPage.favorateList.removeAt(TimeSheetPage.favorateList.length - 1);
                  }
                }
                _controller.value = null;
              } else {
                _justSelected = null;
              }

              Navigator.pop(context);
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ]).show();
    isOk ??= true;
    logger.finest("After Alert = $isOk");
    if (isOk && _justSelected != null && ttype != TimeSlotType.none) {
      setState(() {
        if (ttype == TimeSlotType.after30) {
          widget.item.projectCode2 = _justSelected;
          return;
        }
        if (ttype == TimeSlotType.before30) {
          widget.item.projectCode1 = _justSelected;
          return;
        }
        if (ttype == TimeSlotType.wholeHour) {
          widget.item.projectCode1 = _justSelected;
          widget.item.projectCode2 = _justSelected;
          return;
        }
      });
      _justSelected = null;
    }

    // Dialogs.materialDialog(
    //     msg: 'Are you sure ? you can\'t undo this',
    //     title: "Delete",
    //     color: Colors.white,
    //     context: context,
    //     actions: [
    //       IconsOutlineButton(
    //         onPressed: () {
    //           Navigator.of(context).pop();
    //         },
    //         text: 'Cancel',
    //         iconData: Icons.cancel_outlined,
    //         textStyle: const TextStyle(color: Colors.grey),
    //         iconColor: Colors.grey,
    //       ),
    //       IconsButton(
    //         onPressed: () {},
    //         text: 'Delete',
    //         iconData: Icons.delete,
    //         color: Colors.red,
    //         textStyle: const TextStyle(color: Colors.white),
    //         iconColor: Colors.white,
    //       ),
    //     ]);

    // return TextFormField(
    //   onEditingComplete: () {
    //     if (_controller.text.isNotEmpty) {
    //       widget.item.projectCode1 = _controller.text;
    //       widget.onSaveClicked.call();
    //     }
    //     setState(() {
    //       _editModeMap.clear();
    //     });
    //   },
    //   controller: _controller,
    //   decoration: InputDecoration(hintText: _getText()),
    //   validator: (value) {
    //     if (value == null || value.isEmpty) {
    //       return 'Cannot be empty';
    //     }
    //     return null;
    //   },
    // );
  }

  Widget _favorateProject() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SimpleTags(
        content: TimeSheetPage.favorateList,
        wrapSpacing: 4,
        wrapRunSpacing: 4,
        onTagPress: (tag) {
          logger.finest('pressed $tag');
          _justSelected = tag;
          Navigator.pop(context);
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
      options: TimeSheetPage.projectList,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down),
          labelText: "Project Code 검색"),
      dropdownHeight: 240,
    );
  }

  Widget _getTitle() {
    if (widget.item.timeSlot == '*') {
      return Text('Thank you for your time',
          style: TextStyle(fontSize: 24, color: Colors.grey[500]!));
    }
    if (widget.item.timeSlot == '12') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.restaurant_outlined,
            color: Colors.grey[500]!,
          ),
          Container(
            //padding: const EdgeInsetsDirectional.only(start: 20),
            alignment: AlignmentDirectional.center,
            //color: Colors.grey[300]!,
            child: Text(
              'Lunch Break',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 24, color: Colors.grey[500]!),
            ),
          ),
          Icon(
            Icons.restaurant_outlined,
            color: Colors.grey[500]!,
          ),
        ],
      );
    }
    if (widget.item.projectCode1 == null && widget.item.projectCode2 == null) {
      return Row(
        children: [
          _showProjectCode(
            flex: 2,
            bgColor: Colors.grey[300]!,
            fgColor: Colors.grey[500]!,
            ttype: TimeSlotType.before30,
            title: '<30',
            fontSize: 24,
          ),
          _showProjectCode(
            flex: 6,
            bgColor: Colors.grey[200]!,
            fgColor: Colors.grey[500]!,
            ttype: TimeSlotType.wholeHour,
            title: '0~60',
            fontSize: 24,
          ),
          _showProjectCode(
            flex: 2,
            bgColor: Colors.grey[300]!,
            fgColor: Colors.grey[500]!,
            ttype: TimeSlotType.after30,
            title: '30<',
            fontSize: 24,
          ),
        ],
      );
    }
    if (widget.item.projectCode1 != null && widget.item.projectCode2 == null) {
      return Row(
        children: [
          _showProjectCode(
            flex: 4,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.before30,
            title: widget.item.projectCode1!,
            fontSize: 32,
          ),
          _showProjectCode(
            flex: 4,
            bgColor: Colors.grey[300]!,
            fgColor: Colors.grey[500]!,
            ttype: TimeSlotType.after30,
            title: '30<',
            fontSize: 24,
          ),
          _paintButton(),
          _deleteButton(),
        ],
      );
    }
    if (widget.item.projectCode1 == null && widget.item.projectCode2 != null) {
      return Row(
        children: [
          _showProjectCode(
            flex: 4,
            bgColor: Colors.grey[300]!,
            fgColor: Colors.grey[500]!,
            ttype: TimeSlotType.before30,
            title: '<30',
            fontSize: 24,
          ),
          _showProjectCode(
            flex: 4,
            bgColor: Colors.blue[300]!,
            fgColor: Colors.white,
            ttype: TimeSlotType.after30,
            title: widget.item.projectCode2!,
            fontSize: 32,
          ),
          _paintButton(),
          _deleteButton(),
        ],
      );
    }
    if (widget.item.projectCode1 == widget.item.projectCode2) {
      return Row(
        children: [
          _showProjectCode(
            flex: 8,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.wholeHour,
            title: widget.item.projectCode1!,
            fontSize: 32,
          ),
          _paintButton(),
          _deleteButton(),
        ],
      );
    }
    return Row(
      children: [
        _showProjectCode(
          flex: 4,
          bgColor: Colors.blue[200]!,
          fgColor: Colors.white,
          ttype: TimeSlotType.before30,
          title: widget.item.projectCode1!,
          fontSize: 32,
        ),
        _showProjectCode(
          flex: 4,
          bgColor: Colors.blue[300]!,
          fgColor: Colors.white,
          ttype: TimeSlotType.after30,
          title: widget.item.projectCode2!,
          fontSize: 32,
        ),
        _paintButton(),
        _deleteButton(),
      ],
    );
  }

  Widget _showProjectCode({
    required int flex,
    required Color bgColor,
    required Color fgColor,
    required double fontSize,
    required String title,
    required TimeSlotType ttype,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: AlignmentDirectional.center,
        color: bgColor,
        child: TextButton(
          onPressed: () {
            _editTitle(ttype);
          },
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize, color: fgColor),
          ),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return Expanded(
      flex: 1,
      child: IconButton(
        onPressed: () {
          setState(() {
            widget.item.projectCode1 = null;
            widget.item.projectCode2 = null;
          });
        },
        icon: const Icon(
          Icons.close_outlined,
          //color: Colors.red,
          size: 24,
        ),
      ),
    );
  }

  Widget _paintButton() {
    return Expanded(
      flex: 1,
      child: IconButton(
        onPressed: widget.onPaint,
        icon: const Icon(
          Icons.format_paint_outlined,
          //color: Colors.red,
          size: 24,
        ),
      ),
    );
  }

  // Widget _splitButton() {
  //   return Expanded(
  //     flex: 1,
  //     child: IconButton(
  //       onPressed: widget.onSplit,
  //       icon: const Icon(
  //         Icons.splitscreen_outlined,
  //         //color: Colors.red,
  //         size: 24,
  //       ),
  //     ),
  //   );
  // }

  // String _getText() {
  //   if (widget.item.projectCode1 != null) {
  //     if (widget.item.projectCode2 != null) {
  //       return '${widget.item.projectCode1} / ${widget.item.projectCode2}';
  //     }
  //     return '${widget.item.projectCode1}';
  //   }
  //   if (widget.item.projectCode2 != null) {
  //     return '----- / ${widget.item.projectCode2}';
  //   }
  //   return '';
  // }
}
