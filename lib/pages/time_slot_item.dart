// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
//import 'package:material_dialogs/material_dialogs.dart';
//import 'package:material_dialogs/widgets/buttons/icon_button.dart';
//import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:simple_tags/simple_tags.dart';
import 'package:morphing_text/morphing_text.dart';
import '../common/logger.dart';
import '../model/data_model.dart';

class TimeSlotItem extends StatefulWidget {
  final TimeSlotModel model;
  //final Animation<double> animation;
  final VoidCallback onCopy;
  final GlobalKey<TimeSlotItemState> itemKey;
  const TimeSlotItem({
    required this.itemKey,
    required this.model,
    //required this.animation,
    required this.onCopy,
  }) : super(key: itemKey);

  @override
  State<TimeSlotItem> createState() => TimeSlotItemState();

  void notify() {
    itemKey.currentState!.notify();
  }
}

enum TimeSlotType {
  wholeHour,
  before30,
  after30,
  none,
}

class TimeSlotItemState extends State<TimeSlotItem> {
  //static final Map<String, bool> _editModeMap = {};
  //final TextEditingController _controller = TextEditingController();
  final DropdownEditingController<String> _controller = DropdownEditingController<String>();
  String? _justSelected;
  // ignore: prefer_final_fields
  double _spreadRadius = 1;

  void notify() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return
        //SizeTransition(
        //  key: ValueKey(widget.model.timeSlot),
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
        // tileColor: widget.model.timeSlot == '12' || widget.model.timeSlot == '*'
        //     ? null
        //     : Colors.grey[300]!,
        dense: true,
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        visualDensity: VisualDensity.compact,
        leading: widget.model.timeSlot == '*'
            ? null
            : Container(
                decoration: BoxDecoration(
                  boxShadow: _getShadow(8),
                  shape: BoxShape.circle,
                ),
                // child: CircleAvatar(
                //     backgroundColor: Colors.grey[600]!,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.model.timeSlot,
                      style: TextStyle(fontSize: 24, color: Colors.white)),
                )),
        //),
        //title: (_editModeMap[widget.model.timeSlot] ?? false) ? _editTitle() : _getTitle(),
        title: _getTitle(),
        onTap: () {
          logger.finest('onTap');
          //_editModeMap.clear();
          //_editTitle();
        },
        // onLongPress: () {
        //   setState(() {
        //     _editModeMap.clear();
        //     _editModeMap[widget.model.timeSlot] = true;
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
                String temp = _controller.value!;
                int idx = temp.indexOf('/');
                _justSelected = temp.substring(0, idx);
                if (DataManager.myFavoriteList.isEmpty ||
                    DataManager.myFavoriteList.first != _justSelected!) {
                  if (DataManager.myFavoriteList.contains(_justSelected!)) {
                    DataManager.myFavoriteList.remove(_justSelected!);
                  }
                  DataManager.myFavoriteList.insert(0, _justSelected!);
                  if (DataManager.myFavoriteList.length >= 10) {
                    DataManager.myFavoriteList.removeAt(DataManager.myFavoriteList.length - 1);
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
          widget.model.projectCode2 = _justSelected;
          return;
        }
        if (ttype == TimeSlotType.before30) {
          widget.model.projectCode1 = _justSelected;
          return;
        }
        if (ttype == TimeSlotType.wholeHour) {
          widget.model.projectCode1 = _justSelected;
          widget.model.projectCode2 = _justSelected;
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
    //       widget.model.projectCode1 = _controller.text;
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
        content: DataManager.myFavoriteList,
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
      options: DataManager.projectDescList,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down),
          labelText: "Project Code 검색"),
      dropdownHeight: 240,
    );
  }

  Widget _getTitle() {
    if (widget.model.timeSlot == '*') {
      return Center(
        child: ScaleMorphingText(
          texts: const [
            "Design",
            "is not just",
            "what it looks like",
            "Design",
            "is how it works like.",
            "Steve Jobs",
          ],
          loopForever: true,
          onComplete: () {},
          textStyle: TextStyle(fontSize: 24, color: Colors.grey[500]!),
        ),
      );
      //   Text('Thank you for your time',
      //       style: TextStyle(fontSize: 24, color: Colors.grey[500]!));
    }
    if (widget.model.timeSlot == '12') {
      return //Row(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //children: [
          // Icon(
          //   Icons.restaurant_outlined,
          //   color: Colors.grey[500]!,
          // ),
          Container(
        constraints: BoxConstraints.expand(height: 45),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/lunchBreakBanner.jpg'), // 배경 이미지
          ),
          //boxShadow: _getShadow(8),
        ),
        //padding: const EdgeInsetsDirectional.only(start: 20),
        alignment: AlignmentDirectional.center,
        //color: Colors.grey[300]!,
        child: Text(
          '   Lunch Break',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 24, color: Colors.white, fontStyle: FontStyle.italic),
        ),
      );
      // Icon(
      //   Icons.restaurant_outlined,
      //   color: Colors.grey[500]!,
      // ),
      //],
      //);
    }
    if (widget.model.projectCode1 == null && widget.model.projectCode2 == null) {
      return Row(
        children: [
          _showProjectCode(
            flex: 2,
            bgColor: Colors.grey[300]!,
            fgColor: Colors.grey[500]!,
            ttype: TimeSlotType.before30,
            title: '<30',
            fontSize: 20,
          ),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 6,
            bgColor: Colors.grey[200]!,
            fgColor: Colors.grey[500]!,
            ttype: TimeSlotType.wholeHour,
            title: '0~60',
            fontSize: 24,
          ),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 2,
            bgColor: Colors.grey[300]!,
            fgColor: Colors.grey[500]!,
            ttype: TimeSlotType.after30,
            title: '30<',
            fontSize: 20,
          ),
        ],
      );
    }
    if (widget.model.projectCode1 != null && widget.model.projectCode2 == null) {
      return Row(
        children: [
          _copyButton(),
          _showProjectCode(
            flex: 4,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.before30,
            title: widget.model.projectCode1!,
            fontSize: 28,
          ),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 4,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.after30,
            title: '',
            fontSize: 28,
          ),
          _deleteButton(),
        ],
      );
    }
    if (widget.model.projectCode1 == null && widget.model.projectCode2 != null) {
      return Row(
        children: [
          _copyButton(),
          _showProjectCode(
            flex: 4,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.before30,
            title: '',
            fontSize: 28,
          ),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 4,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.after30,
            title: widget.model.projectCode2!,
            fontSize: 28,
          ),
          _deleteButton(),
        ],
      );
    }
    if (widget.model.projectCode1 == widget.model.projectCode2) {
      return Row(
        children: [
          _copyButton(),
          _showProjectCode(
            flex: 8,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.wholeHour,
            title: widget.model.projectCode1!,
            fontSize: 28,
          ),
          _deleteButton(),
        ],
      );
    }
    return Row(
      children: [
        _copyButton(),
        _showProjectCode(
          flex: 4,
          bgColor: Colors.blue[100]!,
          fgColor: Colors.blue,
          ttype: TimeSlotType.before30,
          title: widget.model.projectCode1!,
          fontSize: 32,
        ),
        SizedBox(width: 5),
        _showProjectCode(
          flex: 4,
          bgColor: Colors.blue[100]!,
          fgColor: Colors.blue,
          ttype: TimeSlotType.after30,
          title: widget.model.projectCode2!,
          fontSize: 32,
        ),
        _deleteButton(),
      ],
    );
  }

  List<BoxShadow>? _getShadow(double blurRadius) {
    return [
      BoxShadow(
        //color: Colors.grey.shade500,
        color: Colors.grey.shade500,
        offset: Offset(-2, -2),
        blurRadius: blurRadius,
        spreadRadius: _spreadRadius,
      ),
      BoxShadow(
        color: Colors.grey.shade500,
        offset: Offset(2, -2),
        blurRadius: blurRadius,
        spreadRadius: _spreadRadius,
      ),
      BoxShadow(
        color: Colors.grey.shade500,
        offset: Offset(-2, 2),
        blurRadius: blurRadius,
        spreadRadius: _spreadRadius,
      ),
      BoxShadow(
        color: Colors.grey.shade500,
        offset: Offset(2, 2),
        blurRadius: blurRadius,
        spreadRadius: _spreadRadius,
      ),
    ];
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
      child: InkWell(
        onTapDown: ((details) {
          logger.finest('onTapDown');
          _editTitle(ttype);
        }),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.all(Radius.circular(18)),
            //boxShadow: isClicked ? _getShadow(8) : null,
          ),
          alignment: AlignmentDirectional.center,
          // child: TextButton(
          //   onPressed: () {
          //     _editTitle(ttype);
          //   },
          //   style: ButtonStyle(visualDensity: VisualDensity.comfortable),
          child: Text(
            title,
            overflow: TextOverflow.clip,
            style: TextStyle(fontSize: fontSize, color: fgColor),
          ),
          //),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return Expanded(
      flex: 1,
      child: SizedBox(
        width: 24,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              setState(() {
                widget.model.projectCode1 = null;
                widget.model.projectCode2 = null;
              });
            },
            icon: const Icon(
              Icons.close_outlined,
              //color: Colors.red,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _copyButton() {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: SizedBox(
          width: 24,
          child: IconButton(
            highlightColor: Colors.red,
            padding: EdgeInsets.all(0),
            onPressed: () {
              widget.onCopy.call();
              setState(() {});
            },
            icon: const Icon(
              Icons.format_paint_outlined,
              //color: Colors.red,
              size: 24,
            ),
          ),
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
  //   if (widget.model.projectCode1 != null) {
  //     if (widget.model.projectCode2 != null) {
  //       return '${widget.model.projectCode1} / ${widget.model.projectCode2}';
  //     }
  //     return '${widget.model.projectCode1}';
  //   }
  //   if (widget.model.projectCode2 != null) {
  //     return '----- / ${widget.model.projectCode2}';
  //   }
  //   return '';
  // }
}
