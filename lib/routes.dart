// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
//import 'package:routemaster/routemaster.dart';
import 'package:time_sheet/pages/project_choice.dart';
import 'common/logger.dart';
import 'pages/login_page.dart';
import 'pages/calendar_page.dart';
import 'pages/setting_page.dart';
import 'pages/stat_page.dart';
import 'pages/time_sheet_wrapper.dart';

class AppRoutes {
  static const String timeSheetPage = '/timeSheetPage';
  static const String settingPage = '/settingPage';
  static const String calendarPage = '/calendarPage';
  static const String projectChoice = '/projectChoice';
  static const String login = '/login';
  static const String statPage = '/statPage';
  static String _lastPage = '';
  static String _currentPage = '';
  static String get lastPage => _lastPage;

  static void _naviPush(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  static push(BuildContext context, String current, String togo) {
    _lastPage = current;
    _currentPage = togo;
    //Routemaster.of(context).replace(togo);
    //logger.finest('push route=${Routemaster.of(context).currentRoute.fullPath}');
    logger.finest('push route=$current --> $togo');

    _naviPush(context, getPageWidget(togo));
  }

  // static pop(BuildContext context) {
  //   Routemaster.of(context).pop();
  //   //logger.finest('pop route=${Routemaster.of(context).currentRoute.fullPath}');
  // }

  //static String getCurrent(BuildContext context) => Routemaster.of(context).currentRoute.fullPath;
  // static bool isCurrentPage(BuildContext context, String page) =>
  //     (Routemaster.of(context).currentRoute.fullPath == page);
  static bool isCurrentPage(BuildContext context, String page) => (_currentPage == page);
}

Widget getPageWidget(String page) {
  switch (page) {
    case AppRoutes.login:
      return LoginPage();
    case AppRoutes.timeSheetPage:
      return TimeSheetWrapper();
    case AppRoutes.settingPage:
      return SettingPage();
    case AppRoutes.calendarPage:
      return CalendarPage();
    case AppRoutes.projectChoice:
      return ProjectChoice();
    case AppRoutes.statPage:
      return StatPage();
  }
  return LoginPage();
}
//final menuKey = GlobalKey<DrawerMenuPageState>();
//DrawerMenuPage menuWidget = DrawerMenuPage(key: menuKey);

// final routesLoggedOut = RouteMap(
//   onUnknownRoute: (_) {
//     return Redirect(AppRoutes.login);
//   },
//   routes: {
//     AppRoutes.login: (_) {
//       return TransitionPage(child: LoginPage());
//     },
//     AppRoutes.timeSheetPage: (_) {
//       return TransitionPage(child: TimeSheetWrapper();
//     },
//     AppRoutes.settingPage: (_) {
//       return TransitionPage(child: SettingPage());
//     },
//     AppRoutes.calendarPage: (_) {
//       return TransitionPage(child: CalendarPage());
//     },
//     AppRoutes.projectChoice: (_) {
//       return TransitionPage(child: ProjectChoice());
//     },
//     AppRoutes.statPage: (_) {
//       return TransitionPage(child: StatPage());
//     },
//   },
// );

// final routesLoggedIn = RouteMap(
//   onUnknownRoute: (_) {
//     return Redirect(AppRoutes.login);
//   },
//   routes: {
//     AppRoutes.timeSheetPage: (_) {
//       return TransitionPage(child: TimeSheetWrapper();
//     },
//   },
// );
