// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'common/logger.dart';
import 'pages/login_page.dart';
import 'pages/time_sheet_page.dart';
import 'pages/calendar_page.dart';
import 'pages/setting_page.dart';

class AppRoutes {
  static const String timeSheetPage = '/timeSheetPage';
  static const String settingPage = '/settingPage';
  static const String calendarPage = '/calendarPage';
  static const String login = '/login';
  static String lastPage = '';

  static void naviPush(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  static push(BuildContext context, String page) {
    Routemaster.of(context).push(page);
    logger.finest('push route=${Routemaster.of(context).currentRoute.fullPath}');
  }

  static pop(BuildContext context) {
    Routemaster.of(context).pop();
    logger.finest('pop route=${Routemaster.of(context).currentRoute.fullPath}');
  }

  static String getCurrent(BuildContext context) => Routemaster.of(context).currentRoute.fullPath;
  static bool isCurrentPage(BuildContext context, String page) =>
      (Routemaster.of(context).currentRoute.fullPath == page);
}

//final menuKey = GlobalKey<DrawerMenuPageState>();
//DrawerMenuPage menuWidget = DrawerMenuPage(key: menuKey);

final routesLoggedOut = RouteMap(
  onUnknownRoute: (_) {
    return Redirect(AppRoutes.login);
  },
  routes: {
    AppRoutes.login: (_) {
      return TransitionPage(child: LoginPage());
    },
    AppRoutes.timeSheetPage: (_) {
      return TransitionPage(child: TimeSheetPage());
    },
    AppRoutes.settingPage: (_) {
      return TransitionPage(child: SettingPage());
    },
    AppRoutes.calendarPage: (_) {
      return TransitionPage(child: CalendarPage());
    },
  },
);

final routesLoggedIn = RouteMap(
  onUnknownRoute: (_) {
    return Redirect(AppRoutes.login);
  },
  routes: {
    AppRoutes.timeSheetPage: (_) {
      return TransitionPage(child: TimeSheetPage());
    },
  },
);
