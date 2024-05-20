// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:livekit_sample/pages/about_page.dart';
import 'package:livekit_sample/pages/user_profile_page.dart';
import 'package:livekit_sample/anchor/anchor_live_page.dart';
import 'package:livekit_sample/audience/live_audience_page.dart';
import 'package:livekit_sample/home/home_page.dart';
import 'package:livekit_sample/auth/login_page.dart';
import 'package:livekit_sample/pages/live_list_page.dart';
import 'router_name.dart';

class RoutesRegister {
  static Map<String, WidgetBuilder> routes(RouteSettings settings) {
    return {
      RouterName.homePage: (context) => const HomePageRoute(),
      RouterName.loginPage: (context) => const LoginRoute(),
      RouterName.liveAudiencePage: (context) => LiveAudiencePage(
          arguments: settings.arguments as Map<String, dynamic>),
      RouterName.liveListPage: (context) => const LiveListPage(),
      RouterName.anchorLivePage: (context) => const AnchorLivePageRoute(),
      RouterName.aboutPage: (context) => const AboutViewPage(),
      RouterName.userProfilePage: (context) => const UserProfilePage(),
    };
  }
}
