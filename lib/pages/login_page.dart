// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:metaballs/metaballs.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:async';
import '../common/logger.dart';
import '../routes.dart';
import '../common/cross_common_job.dart';
import '../api/api_service.dart';
import '../model/data_model.dart';
import '../common/sqlite_wapper.dart';

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginEmailTextEditingController = TextEditingController();
  final _loginPasswordTextEditingController = TextEditingController();

  bool _isHidden = true;
  String _errMsg = '';
  bool _loginProcessing = false;
  bool _initDb = false;

  void _gotoNextPage() {
    if (DataManager.alarmList.isNotEmpty) {
      // 알람이 있을 경우 셋팅 페이지로 이동한다.
      Routemaster.of(context).push(AppRoutes.settingPage);
    } else {
      Routemaster.of(context).push(AppRoutes.timeSheetPage);
    }
  }

  Future<bool> login({required String userId, required String password}) async {
    logger.finest('login');

    try {
      // login
      dynamic loginResult = await ApiService.login(userId, password).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '서버 접속에 실패했습니다';
        });
        return false;
      });
      logger.finest('login call end()');
      Map<String, dynamic> loginData = loginResult;
      String userErrMsg = loginData['err_msg'] ?? '';
      if (userErrMsg.compareTo('succeed') != 0 || loginData['data'] == null) {
        logger.finest('login call errror($userErrMsg)');
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = 'ID 및 패스워드를 확인하세요';//userErrMsg;
        });
        return false;
      }
      logger.finest('login call succeed()');
      Map<String, String> userData = Map<String, String>.from(loginData['data']);
      UserModel userModel = UserModel(userId: userId);
      userModel.sabun = userData['id'] ?? ''; // 사번
      userModel.hm_name = userData['hm_name'] ?? ''; // 이름
      userModel.tm_id = userData['tm_id'] ?? ''; // 부서
      if (userModel.sabun!.isEmpty) {
        // something error
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '사원정보가 없습니다';//'no sabun !!!';
        });
        return false;
      }
      logger.finest('get alarm(${userModel.sabun!})');
      // alarm
      dynamic alarmResult = await ApiService.getAlarmRecord(userModel.sabun!).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '알람정보 접속에 실패했습니다';//'getAlarmRecord Exception !!!';
        });
        return false;
      });
      Map<String, dynamic> alarmData = Map<String, dynamic>.from(alarmResult); //jsonDecode(alarmResult);
      String alarmErrMsg = alarmData['err_msg'] ?? '';
      if (alarmErrMsg.compareTo('succeed') != 0 || alarmData['data'] == null) {
        // something error
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '잘못된 알람정보 입니다';//alarmErrMsg;
        });
        return false;
      }
      List<AlarmModel> alarmModelList = [];
      List<dynamic> dataList = alarmData['data']; //jsonDecode(alarmData['data']);
      //int alarmCount = loginData['count'] ?? 0;
      for (var ele in dataList) {
        Map<String, dynamic> alarm = Map<String, dynamic>.from(ele); //jsonDecode(ele);
        String alarmDate = alarm['date'] ?? '';
        if (alarmDate.isEmpty) continue;
        if (alarm['list'] == null) continue;
        List<dynamic> timeList = List<dynamic>.from(alarm['list']!);
        for (var eleTime in timeList) {
          AlarmModel alarm = AlarmModel(date: alarmDate, timeSlot: eleTime);
          alarmModelList.add(alarm);
        }
      }
      logger.finest('get alarm(${userModel.sabun!})=${alarmModelList.length}');

      logger.finest('get teams()');
      // Teams
      dynamic teamResult = await ApiService.getTeamList().catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '팀정보 접속에 실패했습니다';//'getTeam Exception !!!';
        });
        return false;
      });
      Map<String, dynamic> teamData = Map<String, dynamic>.from(teamResult); //jsonDecode(teamResult);
      String teamErrMsg = teamData['err_msg'] ?? '';
      if (teamErrMsg.compareTo('succeed') != 0 || teamData['data'] == null) {
        // something error
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '잘못된 팀정보 입니다';//teamErrMsg;
        });
        return false;
      }
      List<String> teamList = [];
      List<dynamic> teamDataList = teamData['data']; //jsonDecode(teamData['data']!);
      for (var eleFavor in teamDataList) {
        teamList.add(eleFavor);
      }
      logger.finest('get teamList()=${teamList.length}');

      logger.finest('get favorites(${userModel.sabun!})');
      // favorites
      dynamic favorResult = await ApiService.getMyFavorite(userModel.sabun!).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '즐겨찾기 접속에 실패했습니다';//'getMyFavorite Exception !!!';
        });
        return false;
      });
      Map<String, dynamic> favorData = Map<String, dynamic>.from(favorResult); //jsonDecode(favorResult);
      String favorErrMsg = favorData['err_msg'] ?? '';
      if (favorErrMsg.compareTo('succeed') != 0 || favorData['data'] == null) {
        // something error
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '잘못된 즐겨찾기 정보입니다';//favorErrMsg;
        });
        return false;
      }
      List<String> favorList = [];
      List<dynamic> favorDataList = favorData['data']; //jsonDecode(favorData['data']!);
      for (var eleFavor in favorDataList) {
        favorList.add(eleFavor);
      }
      logger.finest('get favorList(${userModel.sabun!})=${favorList.length}');

      //project list;
      logger.finest('get project(${userModel.tm_id!})');
      dynamic projectResult = await ApiService.getProjectList(userModel.tm_id!).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '프로젝트 접속에 실패했습니다';//'getProjectList Exception !!!';
        });
        return false;
      });
      Map<String, dynamic> projectData = Map<String, dynamic>.from(projectResult); //jsonDecode(projectResult);
      String projectErrMsg = projectData['err_msg'] ?? '';
      if (projectErrMsg.compareTo('succeed') != 0 || projectData['data'] == null) {
        // something error
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = '잘못된 프로젝트정보 입니다';//projectErrMsg;
        });
        return false;
      }
      List<ProjectModel> projectModelList = [];
      List<String> projectDescList = [];

      List<dynamic> projectList = projectData['data']; //jsonDecode(projectData['data']);
      List<dynamic>? projectOthers = projectData['others']; //jsonDecode(projectData['data']);
      //int alarmCount = projectData['count'] ?? 0;
      logger.finest('get projectList=${projectList.length}');
      for (var ele in projectList) {
        Map<String, String> project = Map<String, String>.from(ele); //jsonDecode(ele);
        if (project['code'] == null || project['name'] == null) continue;
        ProjectModel proj = ProjectModel(code: project['code']!, name: project['name']!);
        projectModelList.add(proj);
        projectDescList.add('${proj.code}/${proj.name}');
      }
      if (projectOthers != null) {
        for (var ele in projectOthers) {
          Map<String, String> project = Map<String, String>.from(ele); //jsonDecode(ele);
          if (project['code'] == null || project['name'] == null || project['tm_id'] == null) {
            continue;
          }
          //logger.finest('${project['tm_id']!}, ${project['code']!}');

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
            DataManager.projectOthers[tmId] = [];
          }
          DataManager.projectOthers[tmId]!.add('${proj.code}/${proj.name}');
        }
        logger.finest('projectOthers= ${DataManager.projectOthers.keys.length}');
      }

      //
      DataManager.loginUser = userModel;
      DataManager.alarmList = alarmModelList;
      DataManager.myFavoriteList = favorList;
      DataManager.projectList = projectModelList;
      DataManager.projectDescList = projectDescList;
      DataManager.teamList = teamList;

      Timer.periodic(const Duration(seconds: 1), (timer) async {
        timer.cancel();
        await SqliteWrapper.setAutologinInfo(userId, password);
        _gotoNextPage();
      });
    } catch (e) {
      //logger.severe('It is not json file');
      setState(() {
        colorEffectIndex = 0;
        _loginProcessing = false;
        _errMsg = '접속중 오류가 발생하였습니다';//'something error !!! (${e.toString()})';
      });
      return false;
    }

    return true;
  }

  bool addPasswordCss = false;
  FocusNode passwordFocusNode = FocusNode();
  void fixEdgePasswordRevealButton(FocusNode focusNode) {
    focusNode.unfocus();
    if (addPasswordCss) return;
    addPasswordCss = true; // 한번만 실행
    CrossCommonJob ccj = CrossCommonJob();
    ccj.fixEdgePasswordRevealButton(focusNode);
  }

  int colorEffectIndex = 2;

  Widget _getChild(BuildContext context, double width, double height) {
    return Center(
      child: (_loginProcessing)
          ? SizedBox(
              width: width,
              height: height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  //Text('Connecting...'),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: LoadingIndicator(
                      indicatorType: Indicator.circleStrokeSpin,
                      colors: [Colors.white],
                      strokeWidth: 5,
                      //backgroundColor: Colors.black,
                      //pathBackgroundColor: Colors.black
                    ),
                  )
                ],
              ),
            )
          : AutofillGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12.0),
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      'IQSbz',
                      //textScaleFactor: 1.0, // disables accessibility
                      style: TextStyle(
                        fontSize: 58.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.blue[300]!,
                            blurRadius: 10.0,
                            offset: Offset(5.0, 5.0),
                          ),
                          Shadow(
                            color: Colors.red[300]!,
                            blurRadius: 10.0,
                            offset: Offset(-5.0, 5.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      'Time Sheet',
                      //textScaleFactor: 1.0, // disables accessibility
                      style: TextStyle(
                        fontSize: 58.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.blue[300]!,
                            blurRadius: 10.0,
                            offset: Offset(5.0, 5.0),
                          ),
                          Shadow(
                            color: Colors.red[300]!,
                            blurRadius: 10.0,
                            offset: Offset(-5.0, 5.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60.0),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      autofillHints: const [AutofillHints.email],
                      onTap: () {
                        setState(() {
                          colorEffectIndex = 2;
                        });
                      },
                      controller: _loginEmailTextEditingController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0x99FFFFFF), //Colors.white,
                        hintText: 'ID',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                        prefixIcon: Icon(Icons.person),
                      ),
                      //style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      autofillHints: const [AutofillHints.password],
                      onTap: () {
                        setState(() {
                          colorEffectIndex = 1;
                        });
                      },
                      onChanged: (_) async {
                        fixEdgePasswordRevealButton(passwordFocusNode);
                      },
                      obscureText: _isHidden,
                      controller: _loginPasswordTextEditingController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0x99FFFFFF), //Colors.white,
                        hintText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                        prefixIcon: Icon(Icons.password),
                        suffixIcon: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isHidden = !_isHidden;
                                });
                              },
                              child: Icon(
                                _isHidden ? Icons.visibility : Icons.visibility_off,
                              ),
                            )),
                      ),
                      //style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  SizedBox(
                    width: 180,
                    height: 45,
                    child: ElevatedButton(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      onPressed: () {
                        String userId = _loginEmailTextEditingController.text;
                        if (userId.isEmpty) {
                          setState(() {
                            colorEffectIndex = 0;
                            _loginProcessing = false;
                            _errMsg = 'ID를 입력해주세요';
                          });
                          return;
                        }
                        String password = _loginPasswordTextEditingController.text;
                        if (password.isEmpty) {
                          setState(() {
                            colorEffectIndex = 0;
                            _loginProcessing = false;
                            _errMsg = '비밀번호를 입력해주세요';
                          });
                          return;
                        }

                        setState(() {
                          colorEffectIndex = 4;
                          _loginProcessing = true;
                          Timer.periodic(const Duration(seconds: 1), (timer) {
                            timer.cancel();
                            login(userId: userId, password: password);
                          });
                        });
                      },
                    ),
                  ),
                  // const SizedBox(height: 12.0),
                  // SizedBox(
                  //   width: 160,
                  //   height: 40,
                  //   child: ElevatedButton(
                  //     child: Text(
                  //       'Delete DB',
                  //       style: TextStyle(
                  //         fontSize: 18.0,
                  //       ),
                  //     ),
                  //     onPressed: () async {
                  //       await DataManager.getAlarms(context);
                  //       // ignore: use_build_context_synchronously
                  //       await DataManager.getMyFavorite(context);
                  //       // ignore: use_build_context_synchronously
                  //       //await DataManager.getProjectCodes(context);
                  //       // ignore: use_build_context_synchronously
                  //       setState(() {
                  //         colorEffectIndex = 0;
                  //         _loginProcessing = true;
                  //         Timer.periodic(const Duration(seconds: 1), (timer) {
                  //           timer.cancel();
                  //           Routemaster.of(context).push(AppRoutes.timeSheetPage);
                  //         });
                  //       });
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 12.0),
                  _errMsg.isNotEmpty
                      ? Stack(
                    children: <Widget>[
                      Opacity(
                        opacity: 0.6,
                        child:     Container(
                          width: 260,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red[200], //light blue
                            borderRadius: BorderRadius.all(Radius.circular(45)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _errMsg,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),),
                      Container(
                        width: 260,
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          _errMsg,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                      : const SizedBox(
                          height: 40,
                        ),
                  const SizedBox(height: 32.0),
                  Image(
                    image: AssetImage('assets/sqisoft_logo_white.png'),
                    width: 120,
                    //height: 50,
                  ),
                ],
              ),
            ),
    );
  }


  void _autoLogin() async {
    CrossCommonJob ccj = CrossCommonJob();
    if (ccj.isSupportLocalStorage()) {
      Map<String, String> userInfoMap = await SqliteWrapper.getAutologinInfo();
      String userId = userInfoMap['userId'] ?? '';
      String password = userInfoMap['password'] ?? '';

      if (userId.isNotEmpty && password.isNotEmpty) {
        _loginEmailTextEditingController.text = userId;
        _loginPasswordTextEditingController.text = password;

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
          _loginProcessing = false;
          _initDb = true;
        });
      }
    } else {
      setState(() {
        _loginProcessing = false;
        _initDb = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      timer.cancel();
      _autoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = true;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (CrossCommonJob().isSupportLocalStorage()) {
      isPortrait = MediaQuery.of(context).orientation == Orientation.portrait; // 세로
    } else {
      isPortrait = height > width; // 세로
    }
    return Material(
      child: Container(
        decoration: const BoxDecoration(
            gradient: RadialGradient(center: Alignment.bottomCenter, radius: 1.5, colors: [
          Color.fromARGB(255, 13, 35, 61),
          Colors.black,
        ])),
        child: Metaballs(
          effect: colorsAndEffects[colorEffectIndex].effect,
          glowRadius: 1,
          glowIntensity: 0.6,
          maxBallRadius: 50,
          minBallRadius: 20,
          metaballs: 40,
          color: Colors.grey,
          gradient: LinearGradient(
              colors: colorsAndEffects[colorEffectIndex].colors, begin: Alignment.bottomRight, end: Alignment.topLeft),
          child: (_initDb == false)
              ? Container()
              : ((isPortrait)
                  ? _getChild(context, width, height) // 세로 ==> no scroll
                  : SingleChildScrollView(
                      // 가로 => scroll on
                      scrollDirection: Axis.vertical,
                      child: _getChild(context, width, height),
                    )),
        ),
      ),
    );
  }
}