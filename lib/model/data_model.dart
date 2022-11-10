// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';

import '../common/logger.dart';

class UserModel {
  final String userId;
  String? pwd;
  String? sabun; // 사번
  String? hm_name; // 이름
  String? tm_id; // 부서
  UserModel({required this.userId});
}

class ProjectModel {
  final String code;
  final String name;
  ProjectModel({required this.code, required this.name});
}

class TimeSlotModel {
  final String timeSlot;
  String? projectCode1;
  String? projectCode2;

  TimeSlotModel({
    required this.timeSlot,
    this.projectCode1,
    this.projectCode2,
  });
}

class AlarmModel {
  final String date;
  final String timeSlot;

  AlarmModel({required this.date, required this.timeSlot});
}

class DataManager {
  static UserModel? loginUser;
  static String? showDate;
  static List<String> myFavoriteList = [];
  static List<ProjectModel> projectList = [];
  static List<String> projectDescList = [];
  static Map<String, List<TimeSlotModel>> timeSlotMap = <String, List<TimeSlotModel>>{};
  static List<AlarmModel> alarmList = [];

  static Future<Map<String, dynamic>> loadJson(BuildContext context, String jsonFile) async {
    String jsonString = await DefaultAssetBundle.of(context).loadString('assets/$jsonFile');
    //logger.finest('json=$jsonString');
    return jsonDecode(jsonString);
  }

  static void initDailyTimeSlot(List<TimeSlotModel> retval) {
    for (int i = 7; i < 22; i++) {
      retval.add(TimeSlotModel(timeSlot: (i < 10) ? "0${i.toString()}" : i.toString()));
    }
    retval.add(TimeSlotModel(timeSlot: '*'));
  }

  static bool _validCheck(Map<String, dynamic> jsonMap) {
    if (jsonMap['err_msg'] == null) {
      logger.severe('json Map format error : err_msg is missing');
      return false;
    }
    if (jsonMap['count'] == null) {
      logger.severe('json Map format error : count is missing');
      return false;
    }
    if (jsonMap['data'] == null) {
      logger.severe('json Map format error : data is missing');
      return false;
    }
    String err_msg = jsonMap['err_msg'];
    if (err_msg != 'succeed') {
      logger.severe('get failed : $err_msg');
      return false;
    }
    int count = jsonMap['count'];
    if (count == 0) {
      logger.severe('no data founded');
      return false;
    }
    logger.finest('validCheck ok, data count=$count');
    return true;
  }

  // getData function here ...
  static Future<List<String>> getMyFavorite(BuildContext context) async {
    logger.finest('getMyFavorite() start');

    // if (loginUser == null) {
    //   return [];
    // }
    // TO DO :  get from DB using API
    // ignore: unused_local_variable
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    try {
      // ignore: unused_local_variable
      jsonMap = await loadJson(context, 'get_my_favorite.json');
    } catch (e) {
      logger.severe('json parsing error : $e');
      return [];
    }
    if (_validCheck(jsonMap) == false) {
      return [];
    }
    List<dynamic> dataList = jsonMap['data'];
    myFavoriteList.clear();
    logger.finest('dataList = ${dataList.length}');
    for (String ele in dataList) {
      logger.finest('favorite code=$ele founded');
      myFavoriteList.add(ele);
    }
    logger.finest('getMyFavorite() end');
    return myFavoriteList;
  }

  static Future<List<ProjectModel>> getProjectCodes(BuildContext context) async {
    logger.finest('getProjectCodes() start');

    // if (loginUser == null) {
    //   return [];
    // }
    // TO DO :  get from DB using API
    // ignore: unused_local_variable
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    try {
      // ignore: unused_local_variable
      jsonMap = await loadJson(context, 'get_project_list.json');
    } catch (e) {
      logger.severe('json parsing error : $e');
      return [];
    }
    if (_validCheck(jsonMap) == false) {
      return [];
    }

    List<dynamic> dataList = jsonMap['data'];
    projectList.clear();
    projectDescList.clear();
    logger.finest('dataList = ${dataList.length}');
    for (var ele in dataList) {
      String? code = ele['code'];
      String? name = ele['name'];
      if (code == null || name == null) {
        continue;
      }
      logger.finest('project code=$code,name=$name founded');
      projectList.add(ProjectModel(code: code, name: name));
      projectDescList.add('$code/$name');
    }
    logger.finest('getProjectCodes() end');
    return projectList;
  }

  static Future<Map<String, List<TimeSlotModel>>?> getTimeSlots(BuildContext context) async {
    // if (loginUser == null) {
    //   return null;
    // }
    logger.finest('getTimeSlots($showDate)');
    // TO DO :  get from DB using API
    // ignore: unused_local_variable
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    try {
      jsonMap = await loadJson(context, 'get_time_sheet.json');
    } catch (e) {
      logger.severe('json parsing error : $e');
      return null;
    }
    if (_validCheck(jsonMap) == false) {
      return null;
    }

    List<dynamic> dataList = jsonMap['data'];

    timeSlotMap.clear();
    logger.finest('dataList = ${dataList.length}');
    for (var daily in dataList) {
      String? date = daily['date'];
      if (date == null) {
        logger.warning('no date info founded');
        continue;
      }
      int? count = daily['count'];
      if (count == null || count == 0) {
        logger.warning('no timeslot info founded');
        continue;
      }
      logger.finest('------------slot count=$count');
      List<dynamic>? list = daily['list'];
      if (list == null || list.isEmpty) {
        continue;
      }
      List<TimeSlotModel> eleList = [];
      for (var ele in list) {
        if (ele['time_slot'] == null) {
          continue;
        }
        logger.finest('TimeSlotModel added');
        eleList.add(TimeSlotModel(
          timeSlot: ele['time_slot']!,
          projectCode1: ele['project_code1'],
          projectCode2: ele['project_code2'],
        ));
      }
      timeSlotMap[date] = eleList;
    }
    return timeSlotMap;
  }

  static Future<List<AlarmModel>> getAlarms(BuildContext context) async {
    logger.finest('getAlarms() start');
    // if (loginUser == null) {
    //   return [];
    // }
    // TO DO :  get from DB using API
// ignore: unused_local_variable
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    try {
      // ignore: unused_local_variable
      jsonMap = await loadJson(context, 'get_alarm_record.json');
    } catch (e) {
      logger.severe('json parsing error : $e');
      return [];
    }
    if (_validCheck(jsonMap) == false) {
      return [];
    }
    List<dynamic> dataList = jsonMap['data'];

    timeSlotMap.clear();
    logger.finest('dataList = ${dataList.length}');
    for (var daily in dataList) {
      String? date = daily['date'];
      if (date == null) {
        logger.warning('no date info founded');
        continue;
      }
      int? count = daily['count'];
      if (count == null || count == 0) {
        logger.warning('no timeslot info founded');
        continue;
      }
      logger.finest('------------slot count=$count');
      List<dynamic>? list = daily['list'];
      if (list == null || list.isEmpty) {
        continue;
      }
      for (var timeSlot in list) {
        alarmList.add(AlarmModel(date: date, timeSlot: timeSlot));
      }
    }
    logger.finest('getAlarms() end');
    return alarmList;
  }
}
