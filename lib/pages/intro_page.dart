
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:metaballs/metaballs.dart';
import 'package:time_sheet/api/api_service.dart';
import 'package:time_sheet/common/cross_common_job.dart';
import 'package:time_sheet/common/logger.dart';
import 'package:time_sheet/common/sqlite_wapper.dart';
import 'package:time_sheet/model/data_model.dart';
import 'package:time_sheet/model/project_list_manager.dart';
import 'package:time_sheet/routes.dart';


class ColorsEffectPair {
  final List<Color> colors;
  final MetaballsEffect? effect;
  final String name;

  ColorsEffectPair({
    required this.colors,
    required this.name,
    required this.effect,
  });
}

List<ColorsEffectPair> colorsAndEffects = [
  ColorsEffectPair(colors: [
    const Color.fromARGB(255, 255, 21, 0),
    const Color.fromARGB(255, 255, 153, 0),
  ], effect: MetaballsEffect.follow(), name: 'FOLLOW'),
  ColorsEffectPair(colors: [
    const Color.fromARGB(255, 0, 255, 106),
    const Color.fromARGB(255, 255, 251, 0),
  ], effect: MetaballsEffect.follow(), name: 'FOLLOW'),
  ColorsEffectPair(colors: [
    const Color.fromARGB(255, 90, 60, 255),
    const Color.fromARGB(255, 120, 255, 255),
  ], effect: MetaballsEffect.follow(), name: 'FOLLOW'),
  ColorsEffectPair(colors: [
    const Color.fromARGB(255, 255, 60, 120),
    const Color.fromARGB(255, 237, 120, 255),
  ], effect: MetaballsEffect.follow(), name: 'FOLLOW'),
  ColorsEffectPair(colors: [
    const Color.fromARGB(255, 120, 217, 255),
    const Color.fromARGB(255, 255, 234, 214),
  ], effect: MetaballsEffect.follow(), name: 'FOLLOW'),
];


class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  bool _loginProcessing = false;
  bool _initDb = false;
  bool _showMetaball = false;

  int colorEffectIndex = 2;

  Future<bool> login({required String userId, required String password}) async {
    
    try {
      // >> login
      dynamic loginResult = await ApiService.login(userId, password).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("서버 접속에 실패했습니다.");
        });
        return false;
      });

      Map<String, dynamic> loginData = loginResult;
      String userErrMsg = loginData['err_msg'] ?? '';

      if(userErrMsg.compareTo("succeed") != 0 || loginData["data"] == null) {
        logger.finest("ID 및 패스워드를 확인하세요.");
        setState(() {
          colorEffectIndex = 0;
        });
        return false;
      }

      Map<String, String> userData = Map<String, String>.from(loginData["data"]);
      UserModel userModel = UserModel(userId: userId);
      userModel.sabun = userData["id"] ?? '';
      userModel.hm_name = userData["hm_name"] ?? '';
      userModel.tm_id = userData["tm_id"] ?? '';

      if(userModel.sabun!.isEmpty) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("사원 정보가 없습니다.");
        });
        return false;
      }


      // >> alarm
      dynamic alarmResult = await ApiService.getAlarmRecord(userModel.sabun!).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("알람정보 접속에 실패했습니다.");
        });
        return false;
      });

      Map<String, dynamic> alarmData = Map<String, dynamic>.from(alarmResult);
      String alarmErrMsg = alarmData["err_msg"] ?? "";
      if(alarmErrMsg.compareTo("succeed") != 0 || alarmData["data"] == null) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("잘못된 알람정보입니다.");
        });
        return false;
      }

      List<AlarmModel> alarmModelList = [];
      List<dynamic> dataList = alarmData['data'];

      for(var data in dataList) {
        Map<String, dynamic> alarm = Map<String, dynamic>.from(data);
        String alarmDate = alarm["date"] ?? "";
        if(alarmDate.isEmpty) continue;
        if(alarm["list"] == null) continue;

        List<dynamic> timeList = List<dynamic>.from(alarm["list"]!);
        for(var time in timeList) {
          AlarmModel alarmModel = AlarmModel(date: alarmDate, timeSlot: time);
          alarmModelList.add(alarmModel);
        }
      }


      // >> team
      dynamic teamResult = await ApiService.getPastTeamList().catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("팀 정보 접속에 실패했습니다.");
        });
        return false;
      });

      Map<String, dynamic> teamData = Map<String, dynamic>.from(teamResult);
      String teamErrMsg = teamData["err_msg"] ?? "";

      if(teamErrMsg.compareTo("succeed") != 0 || teamData["data"] == null) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("잘못된 팀 정보입니다.");
        });
        return false;
      }

      List<String> presentTeamList = [];
      List<dynamic> presentTeamDataList = teamData["data"];
      for(var teamData in presentTeamDataList) {
        presentTeamList.add(teamData);
      }

      List<String> pastTeamList = [];
      List<dynamic> pastTeamDataList = teamData["past_data"];
      for(var teamData in pastTeamDataList) {
        pastTeamList.add(teamData);
      }


      // >> favorite project code
      dynamic favorResult = await ApiService.getPastMyFavorite(userModel.sabun!).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("즐겨찾기 접속에 실패했습니다.");
        });
        return false;
      });

      Map<String, dynamic> favorData = Map<String, dynamic>.from(favorResult);
      String favorErrMsg = favorData["err_msg"] ?? "";
      
      if(favorErrMsg.compareTo("succeed") != 0 || favorData["data"] == null) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("잘못된 즐겨찾기 정보입니다.");
        });
        return false;
      }

      DataManager.setFavorProjectData(favorData["data"], favorData["past_data"]);


      // >> project code list
      dynamic projectResult = await ApiService.getPastProjectList(userModel.tm_id!).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("프로젝트 접속에 실패했습니다.");
        });
        return false;
      });

      Map<String, dynamic> projectData = Map<String, dynamic>.from(projectResult);
      String projectErrMsg = projectData["err_msg"] ?? "";

      if(projectErrMsg.compareTo("succeed") != 0 || projectData["data"] == null) {
        setState(() {
          colorEffectIndex = 0;
          logger.finest("잘못된 프로젝트 정보입니다.");
        });
        return false;
      }

      List<dynamic> presentProjectList = projectData["data"];
      List<dynamic>? presentProjectOthers = projectData["others"];
      List<dynamic> pastProjectList = projectData["past_data"];
      List<dynamic>? pastProjectOthers = projectData["past_others"];

      projectDataHolder = ProjectDataManager();
      projectDataHolder!.setProjectList(presentProjectList, presentProjectOthers, presentTeamList, pastProjectList, pastProjectOthers, pastTeamList);


      // data set
      DataManager.loginUser = userModel;
      DataManager.alarmList = alarmModelList;
      DataManager.teamList = presentTeamList;


      Timer.periodic(const Duration(seconds: 1), (timer) async {
        timer.cancel();
        await SqliteWrapper.setAutologinInfo(userId, password);

        if(DataManager.alarmList.isNotEmpty) {
          AppRoutes.push(context, AppRoutes.login, AppRoutes.settingPage);
        } else {
          AppRoutes.push(context, AppRoutes.login, AppRoutes.timeSheetPage);
        }
      });

    } catch (error) {
      setState(() {
        colorEffectIndex = 0;
        logger.finest("접속 중 오류가 발생하였습니다.");
      });
      return false;
    }
    
    return true;
  }

  void _autoLogin() async {
    CrossCommonJob ccj = CrossCommonJob();
    if(ccj.isSupportLocalStorage()) {
      Map<String, String> userInfo = await SqliteWrapper.getAutologinInfo();
      String userId = userInfo["userId"] ?? "";
      String password = userInfo["password"] ?? "";

      if(userId.isNotEmpty && password.isNotEmpty) {
        setState(() {
          _initDb = true;
          _loginProcessing = true;
          colorEffectIndex = 4;
          Timer.periodic(const Duration(seconds: 1), (timer) { 
            timer.cancel();
            login(userId: userId, password: password);
          });
        });
      } else {
        setState(() {
          _initDb = true;
        });
      }
    } else {
      setState(() {
        _initDb = true;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 100), (timer) { 
      timer.cancel();
      _showMetaball = true;
      _autoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = true;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if(CrossCommonJob().isSupportLocalStorage()) {
      isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    } else {
      isPortrait = height > width;
    }
    
    return WillPopScope(
      onWillPop: () async {
        logger.finest("back button press");
        SystemNavigator.pop();
        return false;
      },
      child: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(center: Alignment.bottomCenter, radius: 1.5, colors: [Color.fromARGB(255, 13, 35, 61), Colors.white])
          ),
          child: (_showMetaball == false) ? Container() : Metaballs(
            effect: colorsAndEffects[colorEffectIndex].effect,
            glowRadius: 1,
            glowIntensity: 0.6,
            maxBallRadius: 50,
            minBallRadius: 20,
            metaballs: 40,
            color: Colors.grey,
            gradient: LinearGradient(
              colors: colorsAndEffects[colorEffectIndex].colors,
              begin: Alignment.bottomRight,
              end: Alignment.topLeft
            ),
            child: (_initDb == false) ? Container() : 
              (isPortrait) ? _getChild(context, width, height) :
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _getChild(context, width, height)
                ),
          ),
        ),
      ),
    );

  }

  Widget _getChild(BuildContext context, double width, double height) {
    return Center(
      child: (_loginProcessing) ?
        SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 120,
                height: 120,
                child: LoadingIndicator(
                  indicatorType: Indicator.circleStrokeSpin,
                  colors: [Colors.white],
                  strokeWidth: 5,
                ),
              )
            ],
          ),
        ) : 
        AutofillGroup(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12.0),
              Opacity(
                opacity: 0.7,
                child: Text("IQSbz", 
                  style: TextStyle(
                    fontSize: 48.0, 
                    fontWeight: FontWeight.w800, 
                    color: Colors.white, 
                    shadows: [
                      Shadow(
                        color: Colors.blue[300]!,
                        blurRadius: 10.0,
                        offset: Offset(5.0, 5.0)
                      ),
                      Shadow(
                        color: Colors.red[300]!,
                        blurRadius: 10.0,
                        offset: Offset(-5.0, 5.0)
                      )
                    ]
                  )
                ),
              ),
              Opacity(
                opacity: 0.7,
                child: Text("Time Sheet",
                  style: TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.blue[300]!,
                        blurRadius: 10.0,
                        offset: Offset(5.0, 5.0)
                      ),
                      Shadow(
                        color: Colors.red[300]!,
                        blurRadius: 10.0,
                        offset: Offset(-5.0, 5.0)
                      )
                    ]
                  )
                ),
              ),
              const SizedBox(height: 80.0),
              GestureDetector(
                child: Container(
                  width: 300,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person, color: Colors.blue, size: 30),
                          Text("개인 일정 기록하기", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue))
                        ],
                      ),
                      const Text("누구나 사용 가능합니다.", style: TextStyle(fontSize: 12, color: Colors.blue))
                    ],
                  ),
                ),
                onTap: () {
                  AppRoutes.push(context, AppRoutes.intro, AppRoutes.dayTimeSheetPage);
                },
              ),
              const SizedBox(height: 10),
              GestureDetector(
                child: Container(
                  width: 300,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.work, color: Colors.blue, size: 30),
                          Text("회사 일정 기록하기", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue))
                        ],
                      ),
                      const Text("승인된 유저만 사용 가능합니다.", style: TextStyle(fontSize: 12, color: Colors.blue))
                    ],
                  ),
                ),
                onTap: () {
                  AppRoutes.push(context, AppRoutes.intro, AppRoutes.login);
                },
              ),
              const SizedBox(height: 30),               
              const Image(
              image: AssetImage('assets/sqisoft_logo_white.png'),
                width: 120,
              ),
            ],
          )
        )
    );
  }






}