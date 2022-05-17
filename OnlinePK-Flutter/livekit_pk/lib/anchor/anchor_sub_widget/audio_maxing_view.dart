// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/utils/audio_helper.dart';
import 'package:livekit_pk/values/colors.dart';
import 'package:netease_roomkit/netease_roomkit.dart';

import '../../widgets/slider_widget.dart';

class AudioMaxing{
  late int _musicSelectedIndex;
  late  int _musicPlayVolume = 10;
  late int _effectSelectedIndex;
  late  int _effectPlayVolume = 10;

  int get musicSelectedIndex => _musicSelectedIndex;

  set musicSelectedIndex(int value) {
    _musicSelectedIndex = value;
  }


  int get musicPlayVolume => _musicPlayVolume;

  set musicPlayVolume(int value) {
    _musicPlayVolume = value;
  }

  int get effectSelectedIndex => _effectSelectedIndex;

  set effectSelectedIndex(int value) {
    _effectSelectedIndex = value;
  }

  int get effectPlayVolume => _effectPlayVolume;

  set effectPlayVolume(int value) {
    _effectPlayVolume = value;
  }

  AudioMaxing(this._musicSelectedIndex, this._musicPlayVolume,
      this._effectSelectedIndex, this._effectPlayVolume);
}

class AudioMaxingView extends StatefulWidget {
  final AudioMaxing audioMaxing;
  final audioMaxingcallback;
  const AudioMaxingView({Key? key, required this.audioMaxing, this.audioMaxingcallback}) : super(key: key);

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
            'Sound Accompaniment',
            style: TextStyle(fontSize: 16, color: AppColors.black_333333),
          ),
        ),
        Container(
          color: AppColors.color_e6e7eb,
          height: 1,
        ),
        Container(
          color: AppColors.white,
          margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
          child: Column(
            children: [
              _buildButtonCell('Background Music', 'Music 1', 'Music 2', () {
                if (audioMaxing.musicSelectedIndex == 0) {
                  NELiveKit.instance.mediaController.stopAudioMixing();
                  setState(() {
                    audioMaxing._musicSelectedIndex = -1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                } else {
                  if (audioMaxing._musicSelectedIndex == 1) {
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
                    audioMaxing._musicSelectedIndex = 0;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                }
              }, () {
                if (audioMaxing._musicSelectedIndex == 1) {
                  NELiveKit.instance.mediaController.stopAudioMixing();
                  setState(() {
                    audioMaxing._musicSelectedIndex = -1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                } else {
                  if (audioMaxing._musicSelectedIndex == 0) {
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
                    audioMaxing._musicSelectedIndex = 1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                }
              }, audioMaxing._musicSelectedIndex),
              Container(
                color: AppColors.color_e6e7eb,
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
              _buildButtonCell('Sound Effect', 'Effect 1', 'Effect 2', () {
                if (audioMaxing._effectSelectedIndex == 0) {
                  NELiveKit.instance.mediaController.stopAllEffects();
                  setState(() {
                    audioMaxing._effectSelectedIndex = -1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                } else {
                  if (audioMaxing._effectSelectedIndex == 1) {
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
                    audioMaxing._effectSelectedIndex = 0;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                }
              }, () {
                if (audioMaxing._effectSelectedIndex == 1) {
                  NELiveKit.instance.mediaController.stopAllEffects();
                  setState(() {
                    audioMaxing._effectSelectedIndex = -1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                } else {
                  if (audioMaxing._effectSelectedIndex == 0) {
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
                    audioMaxing._effectSelectedIndex = 1;
                  });
                  widget.audioMaxingcallback(audioMaxing);
                }
              }, audioMaxing._effectSelectedIndex),
              Container(
                color: AppColors.color_e6e7eb,
                height: 1,
              ),
              SizedBox(
                height: 56,
                child: SliderWidget(
                    path: 'assets/images/3.0x/sound_ico.png',
                    onChange: (value) {
                      audioMaxing.effectPlayVolume = value;
                      NELiveKit.instance.mediaController
                          .setEffectSendVolume(audioMaxing._effectSelectedIndex, value);
                      widget.audioMaxingcallback(audioMaxing);
                      NELiveKit.instance.mediaController
                          .setEffectPlaybackVolume(audioMaxing._effectSelectedIndex, value);
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
                      : AppColors.color_f2f3f5,
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
                      : AppColors.color_f2f3f5,
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
