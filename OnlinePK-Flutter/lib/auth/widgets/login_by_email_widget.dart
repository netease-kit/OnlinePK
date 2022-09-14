// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_pk/base/lifecycle_base_state.dart';
import 'package:livekit_pk/base/textutil.dart';
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
import 'package:livekit_pk/values/borders.dart';
import 'package:livekit_pk/values/colors.dart';
import 'package:livekit_pk/values/strings.dart';

class LoginByEmailWidget extends StatefulWidget {
  final String mail;

  LoginByEmailWidget(this.mail);

  @override
  State<StatefulWidget> createState() {
    return LoginByEmailState(mail);
  }
}

class LoginByEmailState extends LifecycleBaseState {
  static const _tag = 'LoginByEmailState';

  final String mail;

  late TextEditingController _emailController;

  late TextEditingController _pwdController;

  late TextEditingController _emailCodeController;

  bool _emailOk = false, _pwdOk = false;

  final bool _pwdShow = false;

  LoginByEmailState(this.mail);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _pwdController = TextEditingController();
    _emailCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    _emailCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildIcon(),
          Container(
            margin: const EdgeInsets.only(top: 43, left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildInputEmail(),
                const SizedBox(height: 10),
                buildInputPwd(),
                buildInputEmailCode(),
                buildAuth()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIcon() {
    return Container(
        // margin: const EdgeInsets.only(top: 24),
        // height: 56,
        // child: Image.asset(
        //   AssetName.iconMail,
        //   package: Packages.uiKit,
        //   fit: BoxFit.none,
        // ),
        );
  }

  Widget buildInputEmail() {
    return Theme(
      data: ThemeData(hintColor: AppColors.greyDCDFE5),
      child: TextField(
        autofocus: true,
        style: const TextStyle(
            color: AppColors.blue_337eff,
            fontSize: 17,
            decoration: TextDecoration.none),
        keyboardType: TextInputType.text,
        cursorColor: AppColors.blue_337eff,
        controller: _emailController,
        textAlign: TextAlign.left,
        keyboardAppearance: Brightness.light,
        onChanged: (value) {
          setState(() {
            _emailOk = !TextUtil.isEmpty(_emailController.text);
          });
        },
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.only(top: 11, bottom: 11),
          hintText: Strings.inputEmailHint,
          hintStyle: TextStyle(fontSize: 17, color: AppColors.greyB0B6BE),
          focusedBorder:
              UnderlineInputBorder(borderSide: Borders.textFieldBorder),
          focusedErrorBorder:
              UnderlineInputBorder(borderSide: Borders.textFieldBorder),
          errorBorder:
              UnderlineInputBorder(borderSide: Borders.textFieldBorder),
        ),
      ),
    );
  }

  Widget buildInputPwd() {
    return Theme(
      data: ThemeData(hintColor: AppColors.greyDCDFE5),
      child: TextField(
        autofocus: false,
        style: const TextStyle(
            color: AppColors.blue_337eff,
            fontSize: 17,
            decoration: TextDecoration.none),
        keyboardType: TextInputType.text,
        cursorColor: AppColors.blue_337eff,
        controller: _pwdController,
        textAlign: TextAlign.left,
        onChanged: (value) {
          setState(() {
            _pwdOk = !TextUtil.isEmpty(_pwdController.text);
          });
        },
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.only(top: 11, bottom: 11),
          hintText: Strings.inputEmailPwdHint,
          hintStyle: TextStyle(fontSize: 17, color: AppColors.greyB0B6BE),
          focusedBorder:
              UnderlineInputBorder(borderSide: Borders.textFieldBorder),
          focusedErrorBorder:
              UnderlineInputBorder(borderSide: Borders.textFieldBorder),
          errorBorder:
              UnderlineInputBorder(borderSide: Borders.textFieldBorder),
        ),
        obscureText: !_pwdShow,
      ),
    );
  }

  Widget buildInputEmailCode() {
    return Theme(
      data: ThemeData(hintColor: AppColors.greyDCDFE5),
      child: TextField(
        autofocus: false,
        style: const TextStyle(
            color: AppColors.blue_337eff,
            fontSize: 17,
            decoration: TextDecoration.none),
        keyboardType: TextInputType.text,
        cursorColor: AppColors.blue_337eff,
        controller: _emailCodeController,
        textAlign: TextAlign.left,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.only(top: 11, bottom: 11),
          hintText: Strings.inputEmailCodeHint,
          hintStyle: TextStyle(fontSize: 17, color: AppColors.greyB0B6BE),
          focusedBorder:
              UnderlineInputBorder(borderSide: Borders.textFieldBorder),
          focusedErrorBorder:
              UnderlineInputBorder(borderSide: Borders.textFieldBorder),
          errorBorder:
              UnderlineInputBorder(borderSide: Borders.textFieldBorder),
        ),
      ),
    );
  }

  Container buildAuth() {
    return Container(
      padding: const EdgeInsets.only(top: 50),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return AppColors.blue_50_337eff;
              }
              return AppColors.blue_337eff;
            }),
            padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(
                    color: _pwdOk && _emailOk
                        ? AppColors.blue_337eff
                        : AppColors.blue_50_337eff,
                    width: 0),
                borderRadius: const BorderRadius.all(Radius.circular(25))))),
        onPressed: _pwdOk && _emailOk ? loginServer : null,
        child: const Text(
          Strings.login,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void loginServer() {
    String email = _emailController.text.toString();
    String password = _pwdController.text.toString();
    String emailCode = _emailCodeController.text.toString();
    if (TextUtil.isEmpty(emailCode)) {
      loginByEmail(email, password).then((result) {
        LiveLog.d(_tag, 'loginByEmail result = ${result.data}');
        if (result.code == 0) {
          ToastUtils.showToast(context, "login success");
          NavUtils.popAndPushNamed(context, RouterName.homePage);
        } else if (result.code == HttpCode.userNotRegister) {
          ToastUtils.showToast(context,
              'user not register already， please check code in your email');
          AppService().sendLoginEmailCode(email);
        } else {
          ToastUtils.showToast(context, result.msg ?? 'net work error');
        }
      });
    } else {
      registerByEmail(email, password, emailCode);
    }
  }

  Future<Result<LoginInfo>> registerByEmail(
      String email, String password, String emailCode) {
    return AppService()
        .registerByEmail(email, password, password, emailCode)
        .then((result) async {
      if (result.code == HttpCode.success) {
        _emailCodeController.text = "";
        ToastUtils.showToast(
            context, 'register success please try login again');
      }
      return result;
    });
  }

  Future<Result<LoginInfo>> loginByEmail(String email, String password) {
    return AppService().loginByEmail(email, password).then((result) async {
      if (result.code == HttpCode.success) {
        var liveKitLoginResult =
            await AuthManager().loginLiveKitWithToken((result.data as LoginInfo).nickname ?? "test",
                (result.data as LoginInfo).accountId, (result.data as LoginInfo).accountToken);
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
