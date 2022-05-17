// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

class _NELivePushService {
  String? _taskID;
  String? _url;

  NERoomLiveStreamTaskInfo? selfLive() {
    if (TextUtils.isEmpty(_url) ||
        TextUtils.isEmpty(_taskID) ||
        TextUtils.isEmpty(NELiveKit.instance._userUuid)) {
      return null;
    }
    return NERoomLiveStreamTaskInfo(
        taskID: _taskID!,
        streamURL: _url!,
        lsMode: NERoomLiveStreamMode.kVideo,
        layout: NERoomLiveStreamLayout(width: 720, height: 1280, users: [
          NERoomLiveStreamUserTranscoding(
            userUuid: NELiveKit.instance._userUuid!,
            x: 0,
            y: 0,
            width: 720,
            height: 1280,
            videoPush: true,
            audioPush: true,
            adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
          )
        ]));
  }

  NERoomLiveStreamTaskInfo? pkLive(bool peerAudio) {
    var userUuid = NELiveKit.instance._userUuid;
    var peerUuid = NELiveKit.instance._anchorLiveInfo.peer?.userUuid;
    if (TextUtils.isEmpty(_url) ||
        TextUtils.isEmpty(_taskID) ||
        TextUtils.isEmpty(userUuid) ||
        TextUtils.isEmpty(peerUuid)) {
      return null;
    }
    return NERoomLiveStreamTaskInfo(
        taskID: _taskID!,
        streamURL: _url!,
        lsMode: NERoomLiveStreamMode.kVideo,
        layout: NERoomLiveStreamLayout(width: 720, height: 640, users: [
          NERoomLiveStreamUserTranscoding(
            userUuid: userUuid!,
            x: 0,
            y: 0,
            width: 360,
            height: 640,
            videoPush: true,
            audioPush: true,
            adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
          ),
          NERoomLiveStreamUserTranscoding(
            userUuid: peerUuid!,
            x: 360,
            y: 0,
            width: 360,
            height: 640,
            videoPush: true,
            audioPush: peerAudio,
            adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
          ),
        ]));
  }

  Future<VoidResult> startLivePush(NERoomContext context, String url) async {
    _taskID = url.hashCode.toString();
    _url = url;
    var task = selfLive();
    if (task != null) {
      var ret = await context.liveController.addLiveStreamTask(task);
      if (ret.code == 1403) {
        // Duplicate taskID
        return context.liveController.updateLiveStreamTask(task);
      }
      return ret;
    } else {
      return Future.value(const NEResult(code: -1, msg: 'task not exist'));
    }
  }

  Future<VoidResult> stopLivePush(NERoomContext context) async {
    if (TextUtils.isNotEmpty(_taskID)) {
      var ret = await context.liveController.removeLiveStreamTask(_taskID!);
      _taskID = null;
      _url = null;
      return Future.value(NEResult(code: ret.code));
    } else {
      return Future.value(const NEResult(code: -1, msg: 'taskID not exist'));
    }
  }

  Future<VoidResult> startPKPush(NERoomContext context) {
    var task = pkLive(true);
    if (task != null) {
      return context.liveController.updateLiveStreamTask(task);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'task not exist'));
    }
  }

  Future<VoidResult> stopPKPush(NERoomContext context) {
    var task = selfLive();
    if (task != null) {
      return context.liveController.updateLiveStreamTask(task);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'task not exist'));
    }
  }

  Future<VoidResult> mutePeerAudio(NERoomContext context) {
    var task = pkLive(false);
    if (task != null) {
      return context.liveController.updateLiveStreamTask(task);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'task not exist'));
    }
  }

  Future<VoidResult> unmutePeerAudio(NERoomContext context) {
    var task = pkLive(true);
    if (task != null) {
      return context.liveController.updateLiveStreamTask(task);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'task not exist'));
    }
  }
}
