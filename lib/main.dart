import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:hycop/hycop.dart';
import 'package:routemaster/routemaster.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'common/logger.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 화면이 두개가 겹치기로 나올려면 해주어야 한다.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // 세로 only
  setupLogger();
  Paint.enableDithering = true;
  initializeDateFormatting().then((_) => runApp(const ProviderScope(child: MainRouteApp())));
}

class MainRouteApp extends ConsumerStatefulWidget {
  const MainRouteApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainRouteAppState();
}

class _MainRouteAppState extends ConsumerState<MainRouteApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Creta Time Sheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        useMaterial3: true,
      ),
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        return routesLoggedOut;
      }),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
