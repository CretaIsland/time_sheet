import 'package:flutter/material.dart';
import 'package:time_sheet/model/data_model.dart';

import '../common/logger.dart';

SlotManager? slotManagerHolder;

class SlotManager extends ChangeNotifier {
  static final Map<String, List<TimeSlotModel>> _timeSlotMap = <String, List<TimeSlotModel>>{};
  late String currentDate;

  SlotManager() {
    DateTime now = DateTime.now();
    currentDate = DataManager.formatter.format(now);
  }

  void notify() => notifyListeners();
  //List<TimeSlotModel> dailyList = [];

  Map<String, List<TimeSlotModel>> get() {
    return _timeSlotMap;
  }

  List<TimeSlotModel> getDate(String date) {
    if (isDateEmpty(date)) {
      initDate(date);
    }
    return _timeSlotMap[date]!;
  }

  List<TimeSlotModel> getCurrentDate() {
    return getDate(currentDate);
  }

  bool isDateNull(String date) {
    return _timeSlotMap[date] == null ? true : false;
  }

  bool isCurrentNull() {
    return isDateNull(currentDate);
  }

  bool isDateEmpty(String date) {
    if (isDateNull(date)) return true;
    return _timeSlotMap[date]!.isEmpty;
  }

  bool isCurrentEmpty() {
    if (isCurrentNull()) return true;
    return _timeSlotMap[currentDate]!.isEmpty;
  }

  void initCurrentDate() {
    initDate(currentDate);
  }

  void initDate(String date) {
    if (_timeSlotMap[date] == null) {
      _timeSlotMap[date] = [];
    } else {
      _timeSlotMap[date]!.clear();
    }
    for (int i = 7; i < 22; i++) {
      _timeSlotMap[date]!
          .add(TimeSlotModel(timeSlot: (i < 10) ? "0${i.toString()}" : i.toString()));
    }
    _timeSlotMap[date]!.add(TimeSlotModel(timeSlot: '*'));
  }

  bool isNeverWritten(String date) {
    if (_timeSlotMap[date] == null) {
      logger.finest('_timeSlotMap is null');
      return true;
    }
    if (_timeSlotMap[date]!.isEmpty) {
      logger.finest('_timeSlotMap is empty');
      return true;
    }
    for (TimeSlotModel element in _timeSlotMap[date]!) {
      if (element.projectCode1 != null || element.projectCode2 != null) {
        return false;
      }
    }
    logger.finest('_timeSlotMap is element is null');
    return true;
  }

  void clearCurrent() {
    clearDate(currentDate);
  }

  void clearDate(String date) {
    if (_timeSlotMap[date] != null) {
      logger.finest('clearDate($date)');
      _timeSlotMap[date]!.clear();
    }
  }

  void addCurrent(TimeSlotModel model) {
    addDate(currentDate, model);
  }

  void addDate(String date, TimeSlotModel model) {
    if (isDateEmpty(date)) {
      initDate(date);
    }
    for (TimeSlotModel toEle in _timeSlotMap[date]!) {
      if (toEle.timeSlot == model.timeSlot) {
        if (model.projectCode1 != null && model.projectCode1!.isEmpty) {
          toEle.projectCode1 = null;
        } else {
          toEle.projectCode1 = model.projectCode1;
        }
        if (model.projectCode2 != null && model.projectCode2!.isEmpty) {
          toEle.projectCode2 = null;
        } else {
          toEle.projectCode2 = model.projectCode2;
        }
        break;
      }
    }
  }

  Future<void> copyToCurrentDate(List<TimeSlotModel> fromList) async {
    initCurrentDate();
    for (var fromEle in fromList) {
      for (TimeSlotModel toEle in _timeSlotMap[currentDate]!) {
        if (toEle.timeSlot == fromEle.timeSlot) {
          if(toEle.timeSlot == '*') break;
          if (fromEle.projectCode1 != null && fromEle.projectCode1!.isEmpty) {
            toEle.projectCode1 = null;
          } else {
            toEle.projectCode1 = fromEle.projectCode1;
          }
          if (fromEle.projectCode2 != null && fromEle.projectCode2!.isEmpty) {
            toEle.projectCode2 = null;
          } else {
            toEle.projectCode2 = fromEle.projectCode2;
          }
          if(toEle.projectCode1 == null && toEle.projectCode2 == null ) break;

          toEle.notifyUI = await DataManager.saveTimeSheet(toEle.timeSlot, toEle.projectCode1 ?? '', toEle.projectCode2 ?? '');
        }
      }
    }
  }
}
