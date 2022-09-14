// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:livekit_pk/auth/widgets/login_by_token_widget.dart';
import 'package:livekit_pk/base/base_state.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends BaseState {
  String? mobile;
  late StreamSubscription streamSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    streamSubscription = eventBus.on<MobileEvent>().listen((MobileEvent data) {
      mobile = data.mobile;
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          //title: Text(''),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: LoginByTokenWidget(mobile ?? ''));
  }
}

EventBus eventBus = EventBus();

class MobileEvent {
  String mobile;

  MobileEvent(this.mobile);
}
