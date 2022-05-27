// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

class LoginResponse {
  final String user;
  final String accessToken;
  final String accountId;

  LoginResponse.fromJson(Map json)
      : user = json['user'] as String,
        accessToken = json['accessToken'] as String,
        accountId = json['accountId'] as String;

  @override
  String toString() {
    return 'LoginResponse{user: $user, accessToken: $accessToken, accountId: $accountId}';
  }
}
