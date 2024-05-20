// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:neliveplayer_core/neliveplayer.dart';

class PlayerPageSecond extends StatefulWidget {
  const PlayerPageSecond({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerSecondState();
}

class _PlayerSecondState extends State<PlayerPageSecond> {
  NELivePlayer? player;

  ///test url
  String url =
      'http://flv591dc843.live.126.net/live/a39ec9202fc74a71b9bc81b762349e99.flv';

  int? currentPosition;

  @override
  void dispose() {
    super.dispose();
    player?.release();
  }

  @override
  void initState() {
    super.initState();
    NELivePlayer.create().then((value) {
      setState(() {
        player = value;
      });
      player?.setPlayerUrl(url);
      player?.setShouldAutoplay(true);
      player?.prepareAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        const TextStyle(backgroundColor: Colors.green, color: Colors.red);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('第二播放页面'),
        ),
        body: Stack(
          children: [
            if (player != null)
              SizedBox(
                width: 1280 / 3,
                height: 720 / 3,
                child: NELivePlayerView(
                  player: player!,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: Column(
                children: [
                  TextButton(
                      onPressed: () {
                        player?.getCurrentPosition().then((value) {
                          setState(() {
                            currentPosition = value;
                          });
                        });
                      },
                      child: Text('getCurrentPosition $currentPosition')),
                  TextButton(
                      onPressed: () {
                        player?.switchContentUrl(
                            'http://flv591dc843.live.126.net/live/a39ec9202fc74a71b9bc81b762349e99.flv');
                      },
                      child: Text('switchContentUrl')),
                  TextButton(
                      onPressed: () {
                        player?.setAutoRetryConfig(NEAutoRetryConfig());
                      },
                      child: Text('setAutoRetryConfig')),
                  TextButton(
                      onPressed: () {
                        player?.setBufferStrategy(
                            PlayerBufferStrategy.nelpDelayPullUp);
                      },
                      child: Text('setBufferStrategy')),
                  TextButton(
                      onPressed: () {
                        player?.setHardwareDecoder(false);
                      },
                      child: Text('setHardwareDecoder')),
                  TextButton(
                      onPressed: () {
                        player?.setMute(false);
                      },
                      child: Text('setMute')),
                  TextButton(
                      onPressed: () {
                        player?.setPlaybackTimeout(9);
                      },
                      child: Text('setPlaybackTimeout')),
                  TextButton(
                      onPressed: () {
                        player?.setVolume(0.9);
                      },
                      child: Text('setVolume')),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    player?.stop();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'stop',
                    style: textStyle,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
