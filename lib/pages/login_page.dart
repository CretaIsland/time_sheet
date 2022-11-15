// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:metaballs/metaballs.dart';
import 'package:loading_indicator/loading_indicator.dart';
//import 'dart:convert';
//import 'dart:collection';
import 'dart:async';
import '../routes.dart';
import '../common/cross_common_job.dart';
//import '../common/creta_scaffold.dart';
//import '../common/logger.dart';
import '../api/api_service.dart';
import '../model/data_model.dart';

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
  ], effect: MetaballsEffect.grow(), name: 'GROW'),
  ColorsEffectPair(colors: [
    const Color.fromARGB(255, 90, 60, 255),
    const Color.fromARGB(255, 120, 255, 255),
  ], effect: MetaballsEffect.speedup(), name: 'SPEEDUP'),
  ColorsEffectPair(colors: [
    const Color.fromARGB(255, 255, 60, 120),
    const Color.fromARGB(255, 237, 120, 255),
  ], effect: MetaballsEffect.ripple(), name: 'RIPPLE'),
  ColorsEffectPair(colors: [
    const Color.fromARGB(255, 120, 217, 255),
    const Color.fromARGB(255, 255, 234, 214),
  ], effect: null, name: 'NONE'),
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

  void _gotoNextPage() {
    Routemaster.of(context).push(AppRoutes.timeSheetPage);
  }

  Future<bool> login({String userId = '', String password = ''}) async {
    if (userId.isEmpty) {
      userId = _loginEmailTextEditingController.text;
    }
    if (password.isEmpty) {
      password = _loginPasswordTextEditingController.text;
    }

    try {
      // login
      dynamic loginResult = await ApiService.login(userId, password).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = 'login Exception !!!';
        });
        return false;
      });
      Map<String, dynamic> loginData = loginResult;
      String userErrMsg = loginData['err_msg'] ?? '';
      if (userErrMsg.compareTo('succeed') != 0 || loginData['data'] == null) {
        // something error
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = userErrMsg;
        });
        return false;
      }
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
          _errMsg = 'no sabun !!!';
        });
        return false;
      }

      // alarm
      dynamic alarmResult = await ApiService.getAlarmRecord(userModel.sabun!).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = 'getAlarmRecord Exception !!!';
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
          _errMsg = alarmErrMsg;
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

      // favorites
      dynamic favorResult = await ApiService.getMyFavorite(userModel.sabun!).catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = 'getMyFavorite Exception !!!';
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
          _errMsg = favorErrMsg;
        });
        return false;
      }
      List<String> favorList = [];
      List<dynamic> favorDataList = favorData['data']; //jsonDecode(favorData['data']!);
      for (var eleFavor in favorDataList) {
        favorList.add(eleFavor);
      }

      //project list;
      //dynamic projectResult = await ApiService.getProjectList(userModel.sabun!).catchError((error, stackTrace) {
      dynamic projectResult = await ApiService.getProjectList('120022').catchError((error, stackTrace) {
        setState(() {
          colorEffectIndex = 0;
          _loginProcessing = false;
          _errMsg = 'getProjectList Exception !!!';
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
          _errMsg = projectErrMsg;
        });
        return false;
      }
      List<ProjectModel> projectModelList = [];
      List<String> projectDescList = [];
      List<dynamic> projectList = projectData['data']; //jsonDecode(projectData['data']);
      //int alarmCount = projectData['count'] ?? 0;
      for (var ele in projectList) {
        Map<String, String> project = Map<String, String>.from(ele); //jsonDecode(ele);
        if (project['code'] == null || project['name'] == null) continue;
        ProjectModel proj = ProjectModel(code: project['code']!, name: project['name']!);
        projectModelList.add(proj);
        projectDescList.add('${proj.code}/${proj.name}');
      }

      //
      DataManager.loginUser = userModel;
      DataManager.alarmList = alarmModelList;
      DataManager.myFavoriteList = favorList;
      DataManager.projectList = projectModelList;
      DataManager.projectDescList = projectDescList;

      Timer.periodic(const Duration(seconds: 1), (timer) {
        timer.cancel();
        _gotoNextPage();
      });
    } catch (e) {
      //logger.severe('It is not json file');
      setState(() {
        colorEffectIndex = 0;
        _loginProcessing = false;
        _errMsg = 'something error !!! (${e.toString()})';
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

  Widget _getChild(BuildContext context) {
    return Container(
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
        child: Center(
          child: (_loginProcessing)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Connecting...'),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: LoadingIndicator(
                        indicatorType: Indicator.circleStrokeSpin,
                        colors: [Colors.white],
                        strokeWidth: 3,
                        //backgroundColor: Colors.black,
                        //pathBackgroundColor: Colors.black
                      ),
                    )
                  ],
                )
              : AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                            hintText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
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
                            border: OutlineInputBorder(),
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
                      const SizedBox(height: 12.0),
                      ElevatedButton(
                        child: Text('Login'),
                        onPressed: () {
                          // _login().whenComplete(() {
                          //   Routemaster.of(context).push(AppRoutes.timeSheetPage);
                          // });
                          setState(() {
                            colorEffectIndex = 0;
                            _loginProcessing = true;
                            login();
                          });
                        },
                      ),
                      const SizedBox(height: 12.0),
                      ElevatedButton(
                        child: Text('Next'),
                        onPressed: () async {
                          await DataManager.getAlarms(context);
                          // ignore: use_build_context_synchronously
                          await DataManager.getMyFavorite(context);
                          // ignore: use_build_context_synchronously
                          await DataManager.getProjectCodes(context);
                          // ignore: use_build_context_synchronously
                          Routemaster.of(context).push(AppRoutes.timeSheetPage);
                        },
                      ),
                      const SizedBox(height: 20.0),
                      _errMsg.isNotEmpty
                          ? Text(
                              _errMsg,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                            )
                          : const SizedBox(
                              height: 10,
                            ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    CrossCommonJob ccj = CrossCommonJob();
    if (ccj.isSupportLocalStorage()) {
      //
      // get id&pwd from sqlite
      //
      String id = 'id';
      String pwd = 'pwd';

      _loginProcessing = true;
      login(userId: id, password: pwd);
    }
    colorEffectIndex = 4;
  }

  @override
  Widget build(BuildContext context) {
    // return CretaScaffold(
    //   title: 'Time Sheet Login',
    //   context: context,
    //   child: Material(
    //     child: _getChild(),
    //   ),
    // ).create();
    return Material(
      child: _getChild(context),
    );
  }
} // TODO Implement this library.
