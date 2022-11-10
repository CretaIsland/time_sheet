// ignore_for_file: non_constant_identifier_names

import 'dart:core';

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
  static List<ProjectModel> projectLists = [];
  static List<TimeSlotModel> timeSlotList = [];
  static List<AlarmModel> alarmList = [];

  // getData function here ...
  static Future<List<String>> getMyFavorite() async {
    if (loginUser == null) {
      return [];
    }

    // Should be async and future
    // TO DO :  get from DB using API
    return myFavoriteList;
  }

  static Future<List<ProjectModel>> getProjectCodes() async {
    if (loginUser == null) {
      return [];
    }
    // Should be async and future
    // TO DO :  get from DB using API
    return projectLists;
  }

  static Future<List<TimeSlotModel>> getTimeSlots() async {
    if (loginUser == null) {
      return [];
    }
    // Should be async and future
    // TO DO :  get from DB using API
    return timeSlotList;
  }

  static Future<List<AlarmModel>> getAlarms() async {
    if (loginUser == null) {
      return [];
    }
    // Should be async and future
    // TO DO :  get from DB using API
    return alarmList;
  }
}
