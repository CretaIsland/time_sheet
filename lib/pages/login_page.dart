// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:time_sheet/routes.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'dart:convert';
import 'package:routemaster/routemaster.dart';
import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../common/creta_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginEmailTextEditingController = TextEditingController();
  final _loginPasswordTextEditingController = TextEditingController();

  bool _isHidden = true;

  Future<void> _login() async {
    String userId = '';
    String password = '';
    final url = Uri.parse('http://localhost:8000/login/');
    http.Client client = http.Client();
    if (client is BrowserClient) {
      //logger.finest('client.withCredentials');
      client.withCredentials = true;
    }
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
    Future.microtask(() {
      focusNode.requestFocus();
      // 자바스크립트 호출
      dynamic ret = js.context.callMethod("fixPasswordCss", []); // index.html에서 fixPasswordCss 참조
    });
  }

  Widget _getChild() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('background.jpg'), // 배경 이미지
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _loginEmailTextEditingController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0x99FFFFFF),//Colors.white,
                    hintText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  //style: const TextStyle(fontSize: 12.0),
                ),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                width: 400,
                child: TextField(
                  onChanged: (_) async {
                    if (kIsWeb) {
                      // only web ==> remove eye-icon of password-field in MS-Edge-Browser
                      fixEdgePasswordRevealButton(passwordFocusNode);
                    }
                  },
                  obscureText: _isHidden,
                  controller: _loginPasswordTextEditingController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0x99FFFFFF),//Colors.white,
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
                onPressed: () { _login().whenComplete(() {
                  Routemaster.of(context).push(AppRoutes.timeSheetPage);
                }); },
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return CretaScaffold(
      title: 'Time Sheet Login',
      context: context,
      child: _getChild(),
    ).create();
  }
}// TODO Implement this library.