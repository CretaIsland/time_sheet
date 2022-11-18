// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
//import 'package:material_dialogs/material_dialogs.dart';
//import 'package:material_dialogs/widgets/buttons/icon_button.dart';
//import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:simple_tags/simple_tags.dart';
import 'package:morphing_text/morphing_text.dart';
import 'package:time_sheet/pages/project_choice.dart';
import '../common/logger.dart';
import '../common/my_flip_card.dart';
import '../common/team_select.dart';
import '../model/data_model.dart';
import 'time_sheet_wrapper.dart';

//import 'package:flutter/foundation.dart' show kIsWeb;

//import '../routes.dart';
//import 'project_code.dart';

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
  bool showPiano = false;

  get slotManagerHolder => null;
  // ignore: prefer_final_fields

  void notify() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //logger.finest('dispose TimeSlotItemState');
    //alert?.dismiss();
    super.dispose();
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
        //color: Colors.white30,
        color: Colors.transparent,
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
                  boxShadow: _getShadow(6, 2),
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
        title: _getTitle(),
        onTap: () {
          logger.finest('onTap');
          tsGlobalKey.currentState?.closeDrawer();
        },
      ),
    );
    //);
  }

  Future<void> _editTitle(TimeSlotType ttype) async {
    logger.finest('_editTitle(${ttype.toString()}');
    // bool? isOk = await runAlertPopUp(ttype).show();
    // isOk ??= true;
    // logger.finest("After Alert = $isOk");
    // if (isOk && _justSelected != null && ttype != TimeSlotType.none) {
    //   if (ttype == TimeSlotType.after30) {
    //     widget.model.projectCode2 = _justSelected;
    //   } else if (ttype == TimeSlotType.before30) {
    //     widget.model.projectCode1 = _justSelected;
    //   } else if (ttype == TimeSlotType.wholeHour) {
    //     widget.model.projectCode1 = _justSelected;
    //     widget.model.projectCode2 = _justSelected;
    //   }
    //   widget.model.notifyUI = await DataManager.saveTimeSheet(
    //       widget.model.timeSlot, widget.model.projectCode1 ?? '', widget.model.projectCode2 ?? '');
    //   DataManager.saveAllMyFavorite();
    //   _justSelected = null;
    //   setState(() {});
    // }

    ProjectChoice.selectedModel = widget.model;
    ProjectChoice.selectedTtype = ttype;
    tsGlobalKey.currentState?.openDrawer();
    //AppRoutes.push(context, AppRoutes.projectChoice);
  }

  Alert runAlertPopUp(TimeSlotType ttype) {
    return Alert(
        style: AlertStyle(alertAlignment: Alignment.topCenter),
        context: context,
        title: "프로젝트 코드를 선택하세요",
        content: Column(
          children: <Widget>[
            _favorateProject(),
            _searchProject(),
            SizedBox(height: 20),
            TeamSelectWidget(controller: _controller),
          ],
        ),
        closeIcon: const Icon(Icons.close_outlined),
        buttons: [
          DialogButton(
            onPressed: onCancel,
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            color: Colors.amber,
            onPressed: () {
              onOK(_controller.value, ttype);
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ]);
  }

  void onFavorite(String tag) {
    logger.finest('pressed $tag');
    _justSelected = tag;
    Navigator.pop(context);
  }

  void onOK(String? tag, TimeSlotType ttype) async {
    if (tag == null) {
      _justSelected = null;

      Navigator.pop(context);
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
    _controller.value = null;
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void onCancel() {
    _justSelected = null;
    Navigator.pop(context);
  }

  Widget _favorateProject() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
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

  Widget _searchProject() {
    return TextDropdownFormField(
      controller: _controller,
      options: DataManager.projectDescList.toList(),
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down),
          labelText: "내 부서 프로젝트 선택"),
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
          'Lunch Break',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 24, color: Colors.white),
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
          _textbutton(
            flex: 2,
            bgColor: Colors.grey[300]!,
            fgColor: Colors.grey[500]!,
            fontSize: 16,
            title: '<30',
            onTapDown: ((details) async {
              logger.finest('onTapDown');
              await _editTitle(TimeSlotType.before30);
            }),
          ),
          // _showProjectCode(
          //   flex: 2,
          //   bgColor: Colors.grey[300]!,
          //   fgColor: Colors.grey[500]!,
          //   ttype: TimeSlotType.before30,
          //   title: '<30',
          //   fontSize: 16,
          // ),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 6,
            bgColor: Colors.grey[200]!,
            fgColor: Colors.grey[500]!,
            ttype: TimeSlotType.wholeHour,
            title: '0~60',
            fontSize: 20,
          ),
          SizedBox(width: 5),
          _textbutton(
            flex: 2,
            bgColor: Colors.grey[300]!,
            fgColor: Colors.grey[500]!,
            fontSize: 16,
            title: '30<',
            onTapDown: ((details) async {
              logger.finest('onTapDown');
              await _editTitle(TimeSlotType.after30);
            }),
          ),
          // _showProjectCode(
          //   flex: 2,
          //   bgColor: Colors.grey[300]!,
          //   fgColor: Colors.grey[500]!,
          //   ttype: TimeSlotType.after30,
          //   title: '30<',
          //   fontSize: 16,
          // ),
        ],
      );
    }
    if (widget.model.projectCode1 != null && widget.model.projectCode2 == null) {
      return Row(
        children: [
          _copyButton(),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 3,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.before30,
            title: widget.model.projectCode1!,
            fontSize: 16,
          ),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 3,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.after30,
            title: '',
            fontSize: 16,
          ),
          SizedBox(width: 5),
          _deleteButton(),
        ],
      );
    }
    if (widget.model.projectCode1 == null && widget.model.projectCode2 != null) {
      return Row(
        children: [
          _copyButton(),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 3,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.before30,
            title: '',
            fontSize: 20,
          ),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 3,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.after30,
            title: widget.model.projectCode2!,
            fontSize: 20,
          ),
          SizedBox(width: 5),
          _deleteButton(),
        ],
      );
    }
    if (widget.model.projectCode1 == widget.model.projectCode2) {
      Widget retval = Row(
        children: [
          _copyButton(),
          SizedBox(width: 5),
          _showProjectCode(
            flex: 6,
            bgColor: Colors.blue[100]!,
            fgColor: Colors.blue,
            ttype: TimeSlotType.wholeHour,
            title: widget.model.projectCode1!,
            fontSize: 24,
          ),
          SizedBox(width: 5),
          _deleteButton(),
        ],
      );
      return retval;
    }
    return Row(
      children: [
        _copyButton(),
        SizedBox(width: 5),
        _showProjectCode(
          flex: 3,
          bgColor: Colors.blue[100]!,
          fgColor: Colors.blue,
          ttype: TimeSlotType.before30,
          title: widget.model.projectCode1!,
          fontSize: 18,
        ),
        SizedBox(width: 5),
        _showProjectCode(
          flex: 3,
          bgColor: Colors.blue[100]!,
          fgColor: Colors.blue,
          ttype: TimeSlotType.after30,
          title: widget.model.projectCode2!,
          fontSize: 18,
        ),
        SizedBox(width: 5),
        _deleteButton(),
      ],
    );
  }

  List<BoxShadow>? _getShadow(double blurRadius, double spreadRadius) {
    return [
      BoxShadow(
        //color: Colors.grey.shade500,
        color: Colors.grey.shade500,
        offset: Offset(-2, -2),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
      BoxShadow(
        color: Colors.grey.shade500,
        offset: Offset(2, -2),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
      BoxShadow(
        color: Colors.grey.shade500,
        offset: Offset(-2, 2),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
      BoxShadow(
        color: Colors.grey.shade500,
        offset: Offset(2, 2),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
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
        onTapDown: ((details) async {
          logger.finest('onTapDown');
          await _editTitle(ttype);
        }),
        child: MyFlipCard(
          key: GlobalKey(),
          front: _flipEle(bgColor, fgColor, fontSize, title),
          back: _flipEle(bgColor, fgColor, fontSize, title),
          doFlip: widget.model.notifyUI,
          onInitEnd: () {
            widget.model.notifyUI = false;
          },
        ),
      ),
    );
  }

  Widget _flipEle(
    Color bgColor,
    Color fgColor,
    double fontSize,
    String title,
  ) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        //color: DataManager.isHoliday(title) ? Colors.grey[200]! : bgColor,
        //color: Colors.white.withOpacity(0.3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: const [
            Colors.white60,
            Colors.white10,
          ],
        ),
        border: Border.all(width: 2, color: Colors.white30),
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      alignment: AlignmentDirectional.center,
      child: Text(
        DataManager.holidayString(title),
        overflow: TextOverflow.clip,
        style: TextStyle(
            fontSize: fontSize, color: DataManager.isHoliday(title) ? Colors.grey[400]! : fgColor),
      ),
      //),
    );
  }

  Widget _textbutton({
    required int flex,
    required Color bgColor,
    required Color fgColor,
    required double fontSize,
    required String title,
    required void Function(TapDownDetails) onTapDown,
  }) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTapDown: onTapDown,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            //color: DataManager.isHoliday(title) ? Colors.grey[200]! : bgColor,
            //color: Colors.white.withOpacity(0.3),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: const [
                Colors.white60,
                Colors.white10,
              ],
            ),
            border: Border.all(width: 2, color: Colors.white30),
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          alignment: AlignmentDirectional.center,
          child: Text(
            DataManager.holidayString(title),
            overflow: TextOverflow.clip,
            style: TextStyle(fontSize: fontSize, color: fgColor),
          ),
          //),
        ),
      ),
    );
  }

  Widget _iconbutton({
    required int flex,
    required Color fgColor,
    required IconData iconData,
    required double iconSize,
    required void Function(TapDownDetails) onTapDown,
  }) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTapDown: onTapDown,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            //color: DataManager.isHoliday(title) ? Colors.grey[200]! : bgColor,
            //color: Colors.white.withOpacity(0.3),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: const [
                Colors.white60,
                Colors.white10,
              ],
            ),
            border: Border.all(width: 2, color: Colors.white60),
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          alignment: AlignmentDirectional.center,
          child: Icon(
            iconData,
            color: fgColor,
            size: iconSize,
          ),
          //),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return _iconbutton(
        flex: 2,
        fgColor: Colors.blue,
        iconData: Icons.close_outlined,
        iconSize: 16,
        onTapDown: (value) async {
          widget.model.notifyUI = await DataManager.saveTimeSheet(widget.model.timeSlot, '', '');
          setState(() {
            widget.model.projectCode1 = null;
            widget.model.projectCode2 = null;
          });
          //slotManagerHolder!.notify();
        });
  }

  Widget _copyButton() {
    return _iconbutton(
        flex: 2,
        fgColor: Colors.blue,
        iconData: Icons.format_paint_outlined,
        iconSize: 16,
        onTapDown: (value) async {
          widget.onCopy.call();
          //setState(() {});
        });
  }
}
