// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:livekit_pk/base/net_util.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/anchor/beauty_cache.dart';
import 'package:livekit_pk/consts.dart';
import 'package:livekit_pk/service/auth/auth_manager.dart';
import 'package:livekit_pk/service/config/app_config.dart';
import 'package:livekit_pk/utils/LiveLog.dart';
import 'package:livekit_pk/utils/audio_helper.dart';
import 'package:livekit_pk/values/style/app_style_util.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'application.dart';
import 'base/base_state.dart';
import 'nav/nav_register.dart';
import 'nav/nav_utils.dart';
import 'nav/router_name.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppStyle.setStatusBarTextBlackColor();
  LiveLog.init().then((value) => print("LiveLog init result = $value"));
  runZonedGuarded<Future<void>>(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      AppConfig().init().then((value) {
        // _initializeFlutterFire();
        var extras = <String, String>{};
        extras["serverUrl"] = AppConfig().liveKitUrl;
        NELiveKit.instance
            .initialize(
                NELiveKitOptions(appKey: AppConfig().appKey, extras: extras))
            .then((value) {
          LiveLog.d(moduleName, "NELiveKit initialize success");
          AuthManager().init().then((e) {
            runApp(NELiveApp());
            if (Platform.isAndroid) {
              var systemUiOverlayStyle = const SystemUiOverlayStyle(
                  systemNavigationBarColor: Colors.black,
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.light);
              SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
            }
          });
        });
        NetUtil().addListener();
      });
    });
  }, (Object error, StackTrace stack) {
    Alog.e(
        tag: 'flutter-crash',
        content: 'crash exception: $error \ncrash stack: $stack');
    // FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class NELiveApp extends StatelessWidget {
  NELiveApp({Key? key}) : super(key: key) {
    AudioHelper().init();
    BeautyCache().init();
  }

  @override
  Widget build(BuildContext context) {
    Application.context = context;
    return MaterialApp(
        builder: BotToastInit(),
        color: Colors.black,
        theme: ThemeData(
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.light)),
        themeMode: ThemeMode.light,
        // navigatorKey: NavUtils.navigatorKey,
        home: const WelcomePage(),
        navigatorObservers: [BotToastNavigatorObserver(), routeObserver],
        // routes: RoutesRegister.routes,
        onGenerateRoute: (settings) {
          WidgetBuilder builder =
              RoutesRegister.routes(settings)[settings.name] as WidgetBuilder;
          return MaterialPageRoute(
              builder: (ctx) => builder(ctx),
              settings: RouteSettings(name: settings.name));
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ]);
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends BaseState<WelcomePage> {
  @override
  void initState() {
    super.initState();
    var config = AppConfig();
    Alog.i(
        tag: 'appInit',
        content:
            'vName=${config.versionName} vCode=${config.versionCode} time=${config.time}');
    loadLoginInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black);
  }

  void loadLoginInfo() {
    AuthManager().autoLogin().then((value) {
      if (value) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
      } else {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.login);
      }
    });
  }
}
