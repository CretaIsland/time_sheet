// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:time_sheet/routes.dart';
import 'package:http/http.dart' as http;
import 'package:routemaster/routemaster.dart';
import 'package:metaballs/metaballs.dart';
import 'dart:convert';
import '../common/cross_common_job.dart';
//import '../common/creta_scaffold.dart';

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

  Future<void> login() async {
    String userId = '';
    String password = '';
    final url = Uri.parse('http://localhost:8000/login/');
    http.Client client = http.Client();
    CrossCommonJob ccj = CrossCommonJob();
    ccj.changeHttpWithCredentials(client);
    // <!-- http.Response response = await http.post(
    http.Response response = await client.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'user_id': userId,
        'password': password,
      },
    ).catchError((error, stackTrace) {
      // error !!!
    });
    // -->
    var responseBody = utf8.decode(response.bodyBytes);
    var jsonData = jsonDecode(responseBody);
    //logger.finest('jsonData=$jsonData');

    if (jsonData.isEmpty) {
      // no data !!!
    } else {
      // bool logined = jsonData['logined'] ?? false;
      // String userId = jsonData['user_id'] ?? '';
      // String serverType = jsonData['server_type'] ?? '';
      // logger.finest('getSession($logined, $userId, $serverType)');
      // if (logined) {
      //   _currentLoginUser = UserModel(userData: {'userId': userId});
      //   HycopFactory.serverType = ServerType.fromString(serverType);
      //   return true;
      // }
    }
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
            colors: colorsAndEffects[colorEffectIndex].colors,
            begin: Alignment.bottomRight,
            end: Alignment.topLeft),
        child: /*Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('background.jpg'), // 배경 이미지
              ),
            ),
            child: Scaffold(
            backgroundColor: Colors.transparent,
            body: */
        Center(
          child: AutofillGroup(
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
                    });
                    login();
                  },
                ),
                const SizedBox(height: 12.0),
                ElevatedButton(
                  child: Text('Next'),
                  onPressed: () => Routemaster.of(context).push(AppRoutes.timeSheetPage),
                ),
                const SizedBox(height: 20.0),
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
