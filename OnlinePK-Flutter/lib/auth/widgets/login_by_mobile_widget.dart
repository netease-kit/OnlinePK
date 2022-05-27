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

class LoginByMobileWidget extends StatefulWidget {
  final String mobile;

  LoginByMobileWidget(this.mobile);

  @override
  State<StatefulWidget> createState() {
    return LoginByMobileState(mobile);
  }
}

class LoginByMobileState extends LifecycleBaseState {
  static const _tag = 'LoginByMobileState';
  final String mobile;
  late TextEditingController _mobileController;
  late TextEditingController _authCodeController;
  bool _btnEnable = false;

  LoginByMobileState(this.mobile);

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController(text: mobile);
    _authCodeController = TextEditingController();
    _mobileController.addListener(() {
      var mobile = TextUtil.replaceAllBlank(_mobileController.text);
      eventBus.fire(MobileEvent(mobile));
    });
    _btnEnable = _mobileController.text.length >= mobileLength;
  }

  @override
  void dispose() {
    _mobileController.dispose();
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
                    Strings.loginByMobile,
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
                              const Text(
                                '+86',
                                style: TextStyle(fontSize: 17),
                              ),
                              const SizedBox(
                                height: 20,
                                child: VerticalDivider(
                                    color: AppColors.colorDCDFE5),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: AppColors.blue_337eff,
                                  keyboardAppearance: Brightness.light,
                                  inputFormatters: [
//                            WhitelistingTextInputFormatter(
//                                RegExp("[a-z,A-Z,0-9]")),
                                    //限制只允许输入字母和数字
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'\d+|s')),
                                    //限制只允许输入数字
                                    LengthLimitingTextInputFormatter(
                                        mobileLength), //限制输入长度不超过13位
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: Strings.hintMobile,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        fontSize: 17,
                                        color: AppColors.colorDCDFE5),
                                    // suffixIcon:
                                    //     TextUtil.isEmpty(_mobileController.text)
                                    //         ? null
                                    //         : ClearIconButton(
                                    //             onPressed: () {
                                    //               _mobileController.clear();
                                    //               setState(() {
                                    //                 _btnEnable = false;
                                    //               });
                                    //             },
                                    //           )
                                  ),
                                  onSubmitted: (value) => getCheckCodeServer(),
                                  onChanged: (value) {
                                    setState(() {
                                      _btnEnable = value.length >= mobileLength;
                                    });
                                  },
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
                                  controller: _authCodeController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: AppColors.blue_337eff,
                                  keyboardAppearance: Brightness.light,
                                  inputFormatters: [
                                    //限制只允许输入字母和数字
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'\d+|s')),
                                    //限制只允许输入数字
                                    LengthLimitingTextInputFormatter(
                                        mobileLength), //限制输入长度不超过13位
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: Strings.enterCheckCode,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        fontSize: 17,
                                        color: AppColors.colorDCDFE5),
                                  ),
                                  onSubmitted: (value) => getCheckCodeServer(),
                                  onChanged: (value) {
                                    setState(() {
                                      _btnEnable = value.isNotEmpty;
                                    });
                                  },
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
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          side: BorderSide(
                              color: _btnEnable
                                  ? AppColors.blue_337eff
                                  : AppColors.blue_50_337eff,
                              width: 0),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25))))),
                  onPressed: _btnEnable ? getCheckCodeServer : null,
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
    String mobile = _mobileController.text.toString();
    String authCode = _authCodeController.text.toString();
    loginByVerifyCode(mobile, authCode).then((result) {
      LiveLog.d(_tag, 'verifyAuthCode result = ${result.data}');
      if (result.code == 0) {
        ToastUtils.showToast(context, "login success");
        NavUtils.popAndPushNamed(context, RouterName.homePage);
      }
    });
  }

  /// 验证验证码
  Future<Result<LoginInfo>> loginByVerifyCode(String mobile, String authCode) {
    return AppService().loginByAuthCode(mobile, authCode).then((result) async {
      if (result.code == HttpCode.success) {
        var liveKitLoginResult =
            await AuthManager().loginLiveKitWithToken(result.data as LoginInfo);
        return result.copy(
            code: liveKitLoginResult.code, msg: liveKitLoginResult.msg);
      } else if (result.code == HttpCode.verifyError ||
          result.code == HttpCode.tokenError ||
          result.code == HttpCode.passwordError ||
          result.code == HttpCode.accountNotExist ||
          result.code == HttpCode.loginPasswordError) {
        AuthState().updateState(state: AuthState.init);

        /// reset
        AuthManager().logout();
      }
      return result;
    });
  }
}
