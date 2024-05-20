// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

class _NELivePushService {
  int backgroundColorValue = 0x220E5A;

  String? _taskID;
  String? _url;

  NERoomLiveStreamTaskInfo? selfLive() {
    if (TextUtils.isEmpty(_url) ||
        TextUtils.isEmpty(_taskID) ||
        TextUtils.isEmpty(NELiveKit.instance._userUuid)) {
      return null;
    }
    return NERoomLiveStreamTaskInfo(
        taskId: _taskID!,
        streamUrl: _url!,
        config: NERoomLiveConfig(singleVideoPassthrough: true),
        mode: NERoomLiveStreamMode.kVideo,
        layout: NERoomLiveStreamLayout(
            width: 720,
            height: 1280,
            userTranscodingList: [
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

  NERoomLiveStreamTaskInfo? onSeatLive(List<String> onSeatUserUuids) {
    if (onSeatUserUuids.isEmpty) {
      return selfLive();
    } else if (onSeatUserUuids.length == 1) {
      return NERoomLiveStreamTaskInfo(
        taskId: _taskID!,
        streamUrl: _url!,
        mode: NERoomLiveStreamMode.kVideo,
        config: NERoomLiveConfig(singleVideoPassthrough: true),
        layout: NERoomLiveStreamLayout(
            width: 720,
            height: 1280,
            backgroundColor: backgroundColorValue,
            userTranscodingList: [
              NERoomLiveStreamUserTranscoding(
                userUuid: NELiveKit.instance.userUuid!,
                x: 0,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[0],
                x: 360,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
            ]),
      );
    } else if (onSeatUserUuids.length == 2) {
      return NERoomLiveStreamTaskInfo(
        taskId: _taskID!,
        streamUrl: _url!,
        config: NERoomLiveConfig(singleVideoPassthrough: true),
        mode: NERoomLiveStreamMode.kVideo,
        layout: NERoomLiveStreamLayout(
            width: 720,
            height: 1280,
            backgroundColor: backgroundColorValue,
            userTranscodingList: [
              NERoomLiveStreamUserTranscoding(
                userUuid: NELiveKit.instance.userUuid!,
                x: 0,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[0],
                x: 360,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[1],
                x: 0,
                y: 430,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
            ]),
      );
    } else if (onSeatUserUuids.length == 3) {
      return NERoomLiveStreamTaskInfo(
        taskId: _taskID!,
        streamUrl: _url!,
        config: NERoomLiveConfig(singleVideoPassthrough: true),
        mode: NERoomLiveStreamMode.kVideo,
        layout: NERoomLiveStreamLayout(
            width: 720,
            height: 1280,
            backgroundColor: backgroundColorValue,
            userTranscodingList: [
              NERoomLiveStreamUserTranscoding(
                userUuid: NELiveKit.instance.userUuid!,
                x: 0,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[0],
                x: 360,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[1],
                x: 0,
                y: 430,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[2],
                x: 360,
                y: 430,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
            ]),
      );
    } else if (onSeatUserUuids.length == 4) {
      return NERoomLiveStreamTaskInfo(
        taskId: _taskID!,
        streamUrl: _url!,
        config: NERoomLiveConfig(singleVideoPassthrough: true),
        mode: NERoomLiveStreamMode.kVideo,
        layout: NERoomLiveStreamLayout(
            width: 720,
            height: 1280,
            backgroundColor: backgroundColorValue,
            userTranscodingList: [
              NERoomLiveStreamUserTranscoding(
                userUuid: NELiveKit.instance.userUuid!,
                x: 0,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[0],
                x: 360,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[1],
                x: 0,
                y: 430,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[2],
                x: 360,
                y: 430,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[3],
                x: 0,
                y: 860,
                width: 360,
                height: 420,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
            ]),
      );
    } else if (onSeatUserUuids.length == 5) {
      return NERoomLiveStreamTaskInfo(
        taskId: _taskID!,
        streamUrl: _url!,
        config: NERoomLiveConfig(singleVideoPassthrough: true),
        mode: NERoomLiveStreamMode.kVideo,
        layout: NERoomLiveStreamLayout(
            width: 720,
            height: 1280,
            backgroundColor: backgroundColorValue,
            userTranscodingList: [
              NERoomLiveStreamUserTranscoding(
                userUuid: NELiveKit.instance.userUuid!,
                x: 0,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[0],
                x: 360,
                y: 0,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[1],
                x: 0,
                y: 430,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[2],
                x: 360,
                y: 430,
                width: 360,
                height: 430,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[3],
                x: 0,
                y: 860,
                width: 360,
                height: 420,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
              NERoomLiveStreamUserTranscoding(
                userUuid: onSeatUserUuids[4],
                x: 360,
                y: 860,
                width: 360,
                height: 420,
                audioPush: true,
                videoPush: true,
                adaption: NERoomLiveStreamVideoScaleMode.kCropFill,
              ),
            ]),
      );
    }
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

  Future<VoidResult> updatePush(
      NERoomContext context, List<String> uuids) async {
    var task = onSeatLive(uuids);
    var ret;
    if (task != null) {
      ret = await context.liveController.updateLiveStreamTask(task);
      return ret;
    } else {
      return Future.value(const NEResult(code: -1, msg: 'update task error'));
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
}
