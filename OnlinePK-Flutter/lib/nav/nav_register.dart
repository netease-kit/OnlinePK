// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/anchor/about_logout_view.dart';
import 'package:livekit_pk/anchor/about_view.dart';
import 'package:livekit_pk/anchor/anchor_live_page.dart';
import 'package:livekit_pk/audience/live_audience_page.dart';
import 'package:livekit_pk/home_page.dart';
import 'package:livekit_pk/auth/login_page.dart';
import 'package:livekit_pk/audience/live_list_page.dart';
import '../home_page.dart';
import 'package:livekit_pk/anchor/start_live_page.dart';
import 'router_name.dart';

class RoutesRegister {
  static Map<String, WidgetBuilder> routes(RouteSettings settings) {
    return {
      RouterName.homePage: (context) => HomePageRoute(),
      RouterName.login: (context) => LoginRoute(),
      RouterName.liveAudiencePage: (context) => LiveAudiencePage(
          arguments: settings.arguments as Map<String, dynamic>),
      RouterName.liveListPage: (context) => const LiveListPage(),
      RouterName.startLivePage: (context) => const StartLivePageRoute(),
      RouterName.anchorLivePageRoute: (context) => AnchorLivePageRoute(
          arguments: (settings.arguments as Map)['detail'] as NELiveDetail,
          isBackCamera: (settings.arguments as Map)['camera'] as bool),
      RouterName.aboutView: (context) => AboutViewRoute(),
      RouterName.aboutLogoutView: (context) => const AboutLogoutViewRoute(),
    };
  }
}
