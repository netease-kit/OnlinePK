// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/values/strings.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_sample/utils/audio_helper.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:netease_roomkit/netease_roomkit.dart';

import '../../widgets/slider_widget.dart';

class AudioMaxing {
  late int musicSelectedIndex;
  late int musicPlayVolume = 10;
  late int effectSelectedIndex;
  late int effectPlayVolume = 10;

  AudioMaxing(this.musicSelectedIndex, this.musicPlayVolume,
      this.effectSelectedIndex, this.effectPlayVolume);
}

class AudioMaxingView extends StatefulWidget {
  final AudioMaxing audioMaxing;
  final Function(AudioMaxing item) audioMaxingcallback;
  const AudioMaxingView(
      {Key? key, required this.audioMaxing, required this.audioMaxingcallback})
      : super(key: key);

  @override
  State<AudioMaxingView> createState() => _AudioMaxingViewState();
}

class _AudioMaxingViewState extends State<AudioMaxingView> {
  _loadSettings() {}

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    AudioMaxing audioMaxing = widget.audioMaxing;
    return Container(
      color: AppColors.white,
      height: 306,
      child: Column(children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
          ),
          alignment: Alignment.center,
          height: 48,
          child: const Text(
            Strings.accompaniment,
            style: TextStyle(fontSize: 16, color: AppColors.black_333333),
          ),
        ),
        Container(
          color: AppColors.colorE6e7eb,
          height: 1,
        ),
        Container(
          color: AppColors.white,
          margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
          child: Column(
            children: [
              _buildButtonCell(
                  Strings.backgroundMusic, Strings.music1, Strings.music2, () {
                if (audioMaxing.musicSelectedIndex == 0) {
                  NELiveKit.instance.mediaController.stopAudioMixing();
                  setState(() {
                    audioMaxing.musicSelectedIndex = -1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                } else {
                  if (audioMaxing.musicSelectedIndex == 1) {
                    NELiveKit.instance.mediaController.stopAudioMixing();
                  }
                  NELiveKit.instance.mediaController
                      .startAudioMixing(NECreateAudioMixingOption(
                    path: AudioHelper().musicPath1,
                    playbackVolume: audioMaxing.musicPlayVolume,
                    sendVolume: audioMaxing.musicPlayVolume,
                    loopCount: 0,
                  ));
                  setState(() {
                    audioMaxing.musicSelectedIndex = 0;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                }
              }, () {
                if (audioMaxing.musicSelectedIndex == 1) {
                  NELiveKit.instance.mediaController.stopAudioMixing();
                  setState(() {
                    audioMaxing.musicSelectedIndex = -1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                } else {
                  if (audioMaxing.musicSelectedIndex == 0) {
                    NELiveKit.instance.mediaController.stopAudioMixing();
                  }
                  NELiveKit.instance.mediaController
                      .startAudioMixing(NECreateAudioMixingOption(
                    path: AudioHelper().musicPath2,
                    playbackVolume: audioMaxing.musicPlayVolume,
                    sendVolume: audioMaxing.musicPlayVolume,
                    loopCount: 0,
                  ));
                  setState(() {
                    audioMaxing.musicSelectedIndex = 1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                }
              }, audioMaxing.musicSelectedIndex),
              Container(
                color: AppColors.colorE6e7eb,
                height: 1,
              ),
              SizedBox(
                height: 56,
                child: SliderWidget(
                    path: 'assets/images/3.0x/sound_ico.png',
                    onChange: (value) {
                      audioMaxing.musicPlayVolume = value;
                      NELiveKit.instance.mediaController
                          .setAudioMixingSendVolume(value);
                      NELiveKit.instance.mediaController
                          .setAudioMixingPlaybackVolume(value);
                      widget.audioMaxingcallback(audioMaxing);
                    },
                    level: audioMaxing.musicPlayVolume),
              ),
              _buildButtonCell(Strings.soundEffect, Strings.soundEffect1,
                  Strings.soundEffect2, () {
                if (audioMaxing.effectSelectedIndex == 0) {
                  NELiveKit.instance.mediaController.stopAllEffects();
                  setState(() {
                    audioMaxing.effectSelectedIndex = -1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                } else {
                  if (audioMaxing.effectSelectedIndex == 1) {
                    NELiveKit.instance.mediaController.stopAllEffects();
                  }
                  NELiveKit.instance.mediaController.playEffect(
                      0,
                      NECreateAudioEffectOption(
                        path: AudioHelper().effectPath1,
                        playbackVolume: audioMaxing.effectPlayVolume,
                        sendVolume: audioMaxing.effectPlayVolume,
                        loopCount: 1,
                      ));
                  setState(() {
                    audioMaxing.effectSelectedIndex = 0;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                }
              }, () {
                if (audioMaxing.effectSelectedIndex == 1) {
                  NELiveKit.instance.mediaController.stopAllEffects();
                  setState(() {
                    audioMaxing.effectSelectedIndex = -1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                } else {
                  if (audioMaxing.effectSelectedIndex == 0) {
                    NELiveKit.instance.mediaController.stopAllEffects();
                  }
                  NELiveKit.instance.mediaController.playEffect(
                      1,
                      NECreateAudioEffectOption(
                        path: AudioHelper().effectPath2,
                        playbackVolume: audioMaxing.effectPlayVolume,
                        sendVolume: audioMaxing.effectPlayVolume,
                        loopCount: 1,
                      ));
                  setState(() {
                    audioMaxing.effectSelectedIndex = 1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                }
              }, audioMaxing.effectSelectedIndex),
              Container(
                color: AppColors.colorE6e7eb,
                height: 1,
              ),
              SizedBox(
                height: 56,
                child: SliderWidget(
                    path: 'assets/images/3.0x/sound_ico.png',
                    onChange: (value) {
                      audioMaxing.effectPlayVolume = value;
                      NELiveKit.instance.mediaController.setEffectSendVolume(
                          audioMaxing.effectSelectedIndex, value);
                      widget.audioMaxingcallback(audioMaxing);
                      NELiveKit.instance.mediaController
                          .setEffectPlaybackVolume(
                              audioMaxing.effectSelectedIndex, value);
                      widget.audioMaxingcallback(audioMaxing);
                    },
                    level: audioMaxing.effectPlayVolume),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildButtonCell(String title, String button1, String button2,
      VoidCallback action1, VoidCallback action2, int? selectedIndex) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.color_222222))),
          SizedBox(
              width: 100,
              height: 32,
              child: MaterialButton(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  color: selectedIndex == 0
                      ? AppColors.blue_337eff
                      : AppColors.colorF2f3f5,
                  onPressed: action1,
                  child: Text(button1,
                      style: TextStyle(
                        color: selectedIndex == 0
                            ? AppColors.white
                            : AppColors.color_222222,
                        fontSize: 14,
                      )))),
          const SizedBox(width: 10),
          SizedBox(
              width: 100,
              height: 32,
              child: MaterialButton(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  color: selectedIndex == 1
                      ? AppColors.blue_337eff
                      : AppColors.colorF2f3f5,
                  onPressed: action2,
                  child: Text(button2,
                      style: TextStyle(
                        color: selectedIndex == 1
                            ? AppColors.white
                            : AppColors.color_222222,
                        fontSize: 14,
                      ))))
        ],
      ),
    );
  }
}
