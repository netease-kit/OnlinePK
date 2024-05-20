// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:neliveplayer_core/neliveplayer.dart';
import 'package:neliveplayer_example/player_page_second.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<PlayerPage> {
  NELivePlayer? player;

  ///test url
  String url =
      'http://flv591dc843.live.126.net/live/a39ec9202fc74a71b9bc81b762349e99.flv';

  String listenerStr = '';

  @override
  void dispose() {
    super.dispose();
    player?.release();
    NELivePlayer.removePreloadUrls([
      'http://flv591dc843.live.126.net/live/a39ec9202fc74a71b9bc81b762349e99.flv'
    ]);
  }

  @override
  void initState() {
    super.initState();
    NELivePlayer.getVersion().then((value) {
      setState(() {
        listenerStr = listenerStr + 'version is $value';
      });
    });
    NELivePlayer.queryPreloadUrls().then((value) {
      setState(() {
        listenerStr = listenerStr +
            '\n queryPreloadUrls key is ${value.keys} value is ${value.values}';
      });
    });
    NELivePlayer.create(
      onPreparedListener: () {
        player?.start();
        setState(() {
          listenerStr = listenerStr + '\n onPrepared';
        });
      },
      onFirstAudioDisplayListener: () {
        setState(() {
          listenerStr = listenerStr + '\n onFirstAudioDisplay';
        });
      },
      onFirstVideoDisplayListener: () {
        setState(() {
          listenerStr = listenerStr + '\n onFirstVideoDisplay';
        });
      },
      onLoadStateChangeListener: (type, extra) {
        setState(() {
          listenerStr = listenerStr + '\n onLoadStateChange state = $type ';
        });
      },
      onVideoSizeChangedListener: (width, height) {
        setState(() {
          listenerStr =
              listenerStr + '\n onVideoSizeChanged width$width :height$height';
        });
      },
      onErrorListener: (what, extra) {
        setState(() {
          listenerStr = listenerStr + '\n onError what$what :extra$extra';
        });
      },
    ).then((value) {
      setState(() {
        player = value;
      });
      player?.setPlayerUrl(url);
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
          title: const Text('播放页面'),
        ),
        body: Stack(
          children: [
            if (player != null)
              SizedBox(
                width: 1280 / 4,
                height: 720 / 4,
                child: NELivePlayerView(
                  player: player!,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: Text(
                listenerStr,
                style: const TextStyle(color: Colors.red, height: 1),
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const PlayerPageSecond();
                  }));
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'second',
                    style: textStyle,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
