// ignore_for_file: non_constant_identifier_names, prefer_final_fields

import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_sheet/api/api_service.dart';
import 'package:time_sheet/model/slot_manager.dart';

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

class TeamModel {
  final String code;
  final String name;
  TeamModel({required this.code, required this.name});
}

class TimeSlotStatModel {
  String project = '';
  double sum = 0;
  TimeSlotStatModel(this.project, this.sum);
}

class TimeSlotModel {
  final String timeSlot;
  String? projectCode1;
  String? projectCode2;

  bool notifyUI = true;

  TimeSlotModel({
    required this.timeSlot,
    this.projectCode1,
    this.projectCode2,
  });
  String _toJson(String date) {
    Map<String, String> aMap = {};
    aMap['date'] = date;
    aMap['time_slot'] = timeSlot;
    aMap['project_code1'] = (projectCode1 != null) ? projectCode1! : '';
    aMap['project_code2'] = (projectCode2 != null) ? projectCode2! : '';
    return jsonEncode(aMap);
  }

  Future<bool> save(String date) async {
    String jsonString = _toJson(date);
    ApiService.setTimeSheet(DataManager.loginUser!.sabun!, jsonString);
    return false;
  }
}

class AlarmModel {
  final String date;
  final String timeSlot;

  AlarmModel({required this.date, required this.timeSlot});
}

class DataManager {
  static DateFormat formatter = DateFormat('yyyy-MM-dd');

  static Map<String, String> holidayMap = {
    'LEG': '법정휴가',
    'CON': '약정휴가',
    'ETC': '기타휴가',
    'all': '전체',
    'AL': '연차',
    'CL': '경조휴가',
    'OL': '공가',
    'HL-A': '오전 반차',
    'HL-P': '오후 반차',
    'RML': '안식월',
    'HL': '반차',
    'ML': '월차',
    'TL': '시차',
    'RL': '대체휴가',
    'BT': '출장',
    'RL-R': '대체휴가 전환',
  };

  static UserModel? loginUser;
  static String? showDate;
  static List<String> myFavoriteList = [];
  static Set<ProjectModel> projectList = {};
  static Map<String, Set<String>> projectOthers = {};
  static Set<String> projectDescList = {};
  static List<String> teamList = [];
  static List<AlarmModel> alarmList = [];
  static List<TimeSlotStatModel> statList = [];

  static isUserLogin() => DataManager.loginUser != null && DataManager.loginUser!.hm_name != null;

  static String getTodayString() {
    return DataManager.formatter.format(DateTime.now());
  }

  static String getFiveDaysBefore(String today) {
    DateTime now = DateTime.parse(today);
    DateTime day = now.subtract(const Duration(days: 5));
    return DataManager.formatter.format(day);
  }

  static Future<Map<String, dynamic>> loadJson(BuildContext context, String jsonFile) async {
    String jsonString = await DefaultAssetBundle.of(context).loadString('assets/$jsonFile');
    //logger.finest('json=$jsonString');
    return jsonDecode(jsonString);
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

  static bool _resultValidCheck(Map<String, dynamic> jsonMap) {
    String? err_msg = jsonMap['err_msg'];
    if (err_msg == null) {
      logger.severe('json Map format error : err_msg is missing');
      return false;
    }
    if (err_msg != 'succeed') {
      logger.severe('set failed : $err_msg');
      return false;
    }

    return true;
  }

  // getData function here ...
  static Future<List<String>> getMyFavorite(BuildContext context) async {
    logger.finest('getMyFavorite() start');
    if (loginUser == null || loginUser!.sabun == null) {
      return [];
    }

    Map<String, dynamic> jsonMap =
        await ApiService.getMyFavorite(loginUser!.sabun!).catchError((error, stackTrace) {
      logger.severe('getMyFavorite failed');
      return false;
    });

    // try {
    //   // ignore: unused_local_variable
    //   jsonMap = await loadJson(context, 'get_my_favorite.json');
    // } catch (e) {
    //   logger.severe('json parsing error : $e');
    //   return [];
    // }
    if (_validCheck(jsonMap) == false) {
      logger.severe('getMyFavorite failed');
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

  static Future<bool> addMyFavorite(String code) async {
    logger.finest('setMyFavorite() start');
    if (loginUser == null || loginUser!.sabun == null) {
      return false;
    }

    Map<String, dynamic> jsonMap =
        await ApiService.addMyFavorite(loginUser!.sabun!, code).catchError((error, stackTrace) {
      logger.severe('getMyFavorite failed 1');
      return false;
    });

    if (_resultValidCheck(jsonMap) == false) {
      logger.severe('getMyFavorite failed 2');
      return false;
    }
    return true;
  }

  static void saveAllMyFavorite() async {
    for (var code in myFavoriteList) {
      await addMyFavorite(code);
    }
  }

  // static Future<List<ProjectModel>> getProjectCodes(BuildContext context) async {
  //   logger.finest('getProjectCodes() start');

  //   // if (loginUser == null) {
  //   //   return [];
  //   // }
  //   // TO DO :  get from DB using API
  //   // ignore: unused_local_variable
  //   Map<String, dynamic> jsonMap = <String, dynamic>{};
  //   try {
  //     // ignore: unused_local_variable
  //     jsonMap = await loadJson(context, 'get_project_list.json');
  //   } catch (e) {
  //     logger.severe('json parsing error : $e');
  //     return [];
  //   }
  //   if (_validCheck(jsonMap) == false) {
  //     return [];
  //   }

  //   List<dynamic> dataList = jsonMap['data'];
  //   projectList.clear();
  //   projectDescList.clear();
  //   logger.finest('dataList = ${dataList.length}');
  //   for (var ele in dataList) {
  //     String? code = ele['code'];
  //     String? name = ele['name'];
  //     if (code == null || name == null) {
  //       continue;
  //     }
  //     logger.finest('project code=$code,name=$name founded');
  //     projectList.add(ProjectModel(code: code, name: name));
  //     projectDescList.add('$code/$name');
  //   }
  //   logger.finest('getProjectCodes() end');
  //   return projectList;
  // }

  static Future<Map<String, List<TimeSlotModel>>?> getTimeSheet() async {
    if (loginUser == null) {
      return null;
    }
    logger.finest('getTimeSheet(${slotManagerHolder!.currentDate})');

    String today = slotManagerHolder!.currentDate;
    String fiveDaysBefore = DataManager.getFiveDaysBefore(slotManagerHolder!.currentDate);

    Map<String, dynamic> jsonMap =
        await ApiService.getTimeSheet(loginUser!.sabun!, fiveDaysBefore, today)
            .catchError((error, stackTrace) {
      logger.severe('getTimeSheet error($error)');
      return null;
    });

    logger.finest('getTimeSheet api call end');
    List<dynamic>? dataList = jsonMap['data'];
    if (dataList == null) {
      logger.warning('getTimeSheet result is null');
      return null;
    }

    logger.finest('dataList = ${dataList.length}');
    for (var daily in dataList) {
      String? date = daily['date'];
      if (date == null) {
        logger.warning('no date info founded');
        continue;
      }
      slotManagerHolder!.clearDate(date);

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
      //List<TimeSlotModel> eleList = [];
      for (var ele in list) {
        if (ele['time_slot'] == null) {
          continue;
        }
        //logger.finest('TimeSlotModel added');
        slotManagerHolder!.addDate(
            date,
            TimeSlotModel(
              timeSlot: ele['time_slot']!,
              projectCode1: ele['project_code1'],
              projectCode2: ele['project_code2'],
            ));
      }
    }
    return slotManagerHolder!.get();
  }

  static Future<List<TimeSlotStatModel>?> getTimeSheetStat() async {
    if (loginUser == null) {
      return null;
    }

    String today = slotManagerHolder!.currentDate;
    String firstDate = '${today.substring(0, 4)}-01-01';

    logger.finest('getTimeSheetStat(${loginUser!.tm_id!}, $firstDate, $today)');

    Map<String, dynamic> jsonMap =
        await ApiService.getTimeSheetStat(loginUser!.tm_id!, firstDate, today)
            .catchError((error, stackTrace) {
      logger.severe('getTimeSheetStat error($error)');
      return null;
    });

    logger.finest('getTimeSheetStat api call end');
    List<dynamic>? dataList = jsonMap['data'];
    if (dataList == null) {
      logger.warning('getTimeSheetStat result is null');
      return null;
    }

    DataManager.statList.clear();
    logger.finest('dataList = ${dataList.length}');
    for (var daily in dataList) {
      String? project = daily['project'];
      if (project == null) {
        logger.warning('no project info founded');
        continue;
      }
      double? sum = daily['sum'];
      if (sum == null || sum == 0) {
        logger.warning('no timeslot info founded');
        continue;
      }
      TimeSlotStatModel aModel = TimeSlotStatModel(project, sum);
      DataManager.statList.add(aModel);
    }
    return DataManager.statList;
  }

  static Future<List<TimeSlotStatModel>?> getTimeSheetStatSimulation(BuildContext context) async {
    logger.finest('getTimeSheetStatSimulation() start');

    Map<String, dynamic> jsonMap = <String, dynamic>{};
    try {
      // ignore: unused_local_variable
      jsonMap = await loadJson(context, 'get_stat.json');
    } catch (e) {
      logger.severe('json parsing error : $e');
      return [];
    }
    if (_validCheck(jsonMap) == false) {
      return [];
    }
    List<dynamic> dataList = jsonMap['data'];
    logger.finest('dataList = ${dataList.length}');
    DataManager.statList.clear();
    logger.finest('dataList = ${dataList.length}');
    for (var daily in dataList) {
      String? project = daily['project'];
      if (project == null) {
        logger.warning('no project info founded');
        continue;
      }
      double? sum = daily['sum'];
      if (sum == null || sum == 0) {
        logger.warning('no timeslot info founded');
        continue;
      }
      TimeSlotStatModel aModel = TimeSlotStatModel(project, sum);
      DataManager.statList.add(aModel);
    }
    return DataManager.statList;
  }

  static Future<bool> _setTimeSheet(String timeSlot, String code1, String code2) async {
    if (loginUser == null) {
      return false;
    }
    logger.finest('setTimeSheet(${slotManagerHolder!.currentDate}, $timeSlot, $code1, $code2)');
    Map<String, String> jsonData = {};
    jsonData["date"] = slotManagerHolder!.currentDate;
    jsonData["time_slot"] = timeSlot;
    jsonData["project_code1"] = code1;
    jsonData["project_code2"] = code2;

    Map<String, dynamic> jsonMap =
        await ApiService.setTimeSheet(loginUser!.sabun!, jsonEncode(jsonData))
            .catchError((error, stackTrace) {
      logger.severe('setTimeSheet failed 1');
      return false;
    });

    if (_resultValidCheck(jsonMap) == false) {
      logger.severe('setTimeSheet failed 2');
      return false;
    }
    return true;
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

  static String holidayString(String code) {
    return holidayMap[code] ?? code;
  }

  static bool isHoliday(String code) {
    return (holidayMap[code] != null);
  }

  static Future<bool> getProject() async {
    logger.finest('get project(${loginUser!.tm_id!})');
    dynamic projectResult =
        await ApiService.getProjectList(loginUser!.tm_id!).catchError((error, stackTrace) {
      return false;
    });
    Map<String, dynamic> projectData =
        Map<String, dynamic>.from(projectResult); //jsonDecode(projectResult);
    String projectErrMsg = projectData['err_msg'] ?? '';
    if (projectErrMsg.compareTo('succeed') != 0 || projectData['data'] == null) {
      return false;
    }

    //List<ProjectModel> projectModelList = [];
    //List<String> projectDescList = [];

    // DataManager.projectList.clear();
    // DataManager.projectDescList.clear();
    // DataManager.projectOthers.clear();

    List<dynamic> dataList = projectData['data']; //jsonDecode(projectData['data']);
    List<dynamic>? othersList = projectData['others']; //jsonDecode(projectData['data']);
    //int alarmCount = projectData['count'] ?? 0;
    logger.finest('get projectList=${dataList.length}');
    for (var ele in dataList) {
      Map<String, String> project = Map<String, String>.from(ele); //jsonDecode(ele);
      if (project['code'] == null || project['name'] == null) continue;
      ProjectModel proj = ProjectModel(code: project['code']!, name: project['name']!);
      DataManager.projectList.add(proj);
      DataManager.projectDescList.add('${proj.code}/${proj.name}');
    }
    if (othersList != null) {
      for (var ele in othersList) {
        Map<String, String> project = Map<String, String>.from(ele); //jsonDecode(ele);
        if (project['code'] == null || project['name'] == null || project['tm_id'] == null) {
          continue;
        }
        ProjectModel proj = ProjectModel(code: project['code']!, name: project['name']!);

        String tmId = project['tm_id']!;
        for (var team in teamList) {
          if (team.length > tmId.length && team.substring(0, tmId.length) == tmId) {
            tmId = team;
            break;
          }
        }
        if (DataManager.projectOthers[tmId] == null) {
          logger.finest(project['tm_id']!);
          DataManager.projectOthers[tmId] = {};
        }
        DataManager.projectOthers[tmId]!.add('${proj.code}/${proj.name}');
      }
      logger.finest('projectOthers= ${DataManager.projectOthers.keys.length}');
    }
    return true;
  }

  static Future<bool> saveTimeSheet(String slot, String? code1, String? code2) async {
    await DataManager._setTimeSheet(slot, code1 ?? '', code2 ?? '');
    return true;
  }
}
