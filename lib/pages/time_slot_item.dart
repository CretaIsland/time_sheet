import 'package:flutter/material.dart';

class TimeSlotModel {
  TimeSlotModel({
    required this.timeSlot,
    this.projectCode1,
    this.projectCode2,
  });
  String timeSlot;
  String? projectCode1;
  String? projectCode2;
}

class TimeSlotItem extends StatefulWidget {
  final TimeSlotModel item;
  //final Animation<double> animation;
  final VoidCallback onDelete;
  final VoidCallback onSaveClicked;
  final VoidCallback onSplit;
  final VoidCallback onPaint;
  const TimeSlotItem({
    Key? key,
    required this.item,
    //required this.animation,
    required this.onDelete,
    required this.onSaveClicked,
    required this.onSplit,
    required this.onPaint,
  }) : super(key: key);

  @override
  State<TimeSlotItem> createState() => _TimeSlotItemState();
}

class _TimeSlotItemState extends State<TimeSlotItem> {
  static final Map<String, bool> _editModeMap = {};

  final TextEditingController _controller = TextEditingController();

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
        tileColor: widget.item.timeSlot == '12' ? null : Colors.grey[300]!,
        dense: true,
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        visualDensity: VisualDensity.compact,
        leading:
            Text(widget.item.timeSlot, style: TextStyle(fontSize: 32, color: Colors.grey[500]!)),
        title: (_editModeMap[widget.item.timeSlot] ?? false)
            ? TextFormField(
                onEditingComplete: () {
                  if (_controller.text.isNotEmpty) {
                    widget.item.projectCode1 = _controller.text;
                    widget.onSaveClicked.call();
                  }
                  setState(() {
                    _editModeMap.clear();
                  });
                },
                controller: _controller,
                decoration: InputDecoration(hintText: _getText()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cannot be empty';
                  }
                  return null;
                })
            : _getTitle(),
        onTap: () {
          _editModeMap.clear();
        },
        onLongPress: () {
          setState(() {
            _editModeMap.clear();
            _editModeMap[widget.item.timeSlot] = true;
          });
        },
      ),
    );
    //);
  }

  Widget _getTitle() {
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
          Expanded(
            flex: 2,
            child: Container(
              alignment: AlignmentDirectional.center,
              color: Colors.grey[300]!,
              child: Text(
                '>30',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 24, color: Colors.grey[500]!),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              alignment: AlignmentDirectional.center,
              color: Colors.grey[200]!,
              child: Text(
                '0~60',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 24, color: Colors.grey[500]!),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: AlignmentDirectional.center,
              color: Colors.grey[300]!,
              child: Text(
                '30<',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 24, color: Colors.grey[500]!),
              ),
            ),
          ),
        ],
      );
    }
    if (widget.item.projectCode1 != null && widget.item.projectCode2 == null) {
      return Row(
        children: [
          Expanded(
            flex: 8,
            child: Container(
              alignment: AlignmentDirectional.center,
              color: Colors.blue[100]!,
              child: Text(
                widget.item.projectCode1!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          _paintButton(),
          //_splitButton(),
          _deleteButton(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            alignment: AlignmentDirectional.center,
            color: Colors.blue[200],
            child: widget.item.projectCode1 != null
                ? Text(
                    widget.item.projectCode1!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            alignment: AlignmentDirectional.center,
            color: Colors.blue[300],
            child: widget.item.projectCode2 != null
                ? Text(
                    widget.item.projectCode2!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
        ),
        _paintButton(),
        //_splitButton(),
        _deleteButton(),
      ],
    );
  }

  Widget _deleteButton() {
    return Expanded(
      flex: 1,
      child: IconButton(
        onPressed: widget.onDelete,
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

  String _getText() {
    if (widget.item.projectCode1 != null) {
      if (widget.item.projectCode2 != null) {
        return '${widget.item.projectCode1} / ${widget.item.projectCode2}';
      }
      return '${widget.item.projectCode1}';
    }
    if (widget.item.projectCode2 != null) {
      return '----- / ${widget.item.projectCode2}';
    }
    return '';
  }
}
