// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:livekit_pk/base/lifecycle_base_state.dart';
import 'package:livekit_pk/base/textutil.dart';
import 'package:livekit_pk/consts.dart';
import 'package:livekit_pk/auth/login_page.dart';
import 'package:livekit_pk/nav/nav_utils.dart';
import 'package:livekit_pk/nav/router_name.dart';
import 'package:livekit_pk/service/app_service.dart';
import 'package:livekit_pk/service/auth/auth_manager.dart';
import 'package:livekit_pk/service/auth/auth_state.dart';
import 'package:livekit_pk/service/auth/login_info.dart';
import 'package:livekit_pk/service/client/http_code.dart';
import 'package:livekit_pk/service/response/result.dart';
import 'package:livekit_pk/utils/LiveLog.dart';
import 'package:livekit_pk/utils/toast_utils.dart';
import 'package:livekit_pk/values/colors.dart';
import 'package:livekit_pk/values/strings.dart';
import 'package:livekit_pk/widgets/mask_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginByTokenWidget extends StatefulWidget {
  final String mobile;

  LoginByTokenWidget(this.mobile);

  @override
  State<StatefulWidget> createState() {
    return LoginByTokenState(mobile);
  }
}

class LoginByTokenState extends LifecycleBaseState {
  static const _tag = 'LoginByMobileState';
  final String mobile;
  late TextEditingController _accountIdController;
  late TextEditingController _accountTokenController;
  bool _btnEnable = false;

  LoginByTokenState(this.mobile);

  @override
  void initState() {
    super.initState();
    _accountIdController = TextEditingController(text: mobile);
    _accountTokenController = TextEditingController();
    _accountIdController.addListener(() {
      var mobile = TextUtil.replaceAllBlank(_accountIdController.text);
      eventBus.fire(MobileEvent(mobile));
    });
    _btnEnable = _accountIdController.text.length >= mobileLength;
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_statements
    // LoginModelProvider.of(context).loginByMobile;
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 30, top: 16),
                  child: const Text(
                    Strings.loginByToken,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.black_222222,
                      fontWeight: FontWeight.w500,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                    height: 150,
                    margin: const EdgeInsets.only(left: 30, top: 24, right: 30),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryElement,
                    ),
                    child: Column(children: <Widget>[
                      Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topLeft,
                          children: <Widget>[
                            Row(children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _accountIdController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: AppColors.blue_337eff,
                                  keyboardAppearance: Brightness.light,
                                  decoration: const InputDecoration(
                                    hintText: Strings.hintAccountId,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        fontSize: 17,
                                        color: AppColors.colorDCDFE5),
                                  ),
                                ),
                                flex: 1,
                              ),
                            ]),
                            Container(
                              margin: const EdgeInsets.only(top: 35),
                              child: const Divider(
                                thickness: 1,
                                color: AppColors.colorDCDFE5,
                              ),
                            ),
                          ]),
                      Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topLeft,
                          children: <Widget>[
                            Row(children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _accountTokenController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: AppColors.blue_337eff,
                                  keyboardAppearance: Brightness.light,
                                  decoration: const InputDecoration(
                                    hintText: Strings.hintAccountToken,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        fontSize: 17,
                                        color: AppColors.colorDCDFE5),
                                  ),
                                ),
                                flex: 1,
                              ),
                            ]),
                            Container(
                              margin: const EdgeInsets.only(top: 35),
                              child: const Divider(
                                thickness: 1,
                                color: AppColors.colorDCDFE5,
                              ),
                            ),
                          ]),
                    ])),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.only(left: 30, top: 50, right: 30),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return AppColors.blue_50_337eff;
                        }
                        return AppColors.blue_337eff;
                      }),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 13)),
                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                          side: BorderSide(
                              color: AppColors.blue_337eff,
                              width: 0),
                          borderRadius:
                              BorderRadius.all(Radius.circular(25))))),
                  onPressed: getCheckCodeServer,
                  child: const Text(
                    Strings.login,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void getCheckCodeServer() {
    String accountId = _accountIdController.text.toString();
    String accountToken = _accountTokenController.text.toString();
    loginByToken(accountId, accountToken).then((result) {
      LiveLog.d(_tag, 'verifyAuthCode result = ${result.code}');
      if (result.code == 0) {
        ToastUtils.showToast(context, "login success");
        NavUtils.popAndPushNamed(context, RouterName.homePage);
      }
    });
  }

  Future<Result<void>> loginByToken(String accountId, String accountToken) {
        var liveKitLoginResult = AuthManager().loginLiveKitWithToken("test",
                accountId, accountToken);
        return liveKitLoginResult;
  }
}
