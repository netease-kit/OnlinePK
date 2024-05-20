# NELivePlayer for Flutter

Flutter NELivePlayer from Netease

Know more about `NELivePlayer`, visit [website](https://yunxin.163.com/im)

PS:this player must be used with [nertc](https://pub.dev/packages/nertc)

## Getting Started

### step 1,add dependencies
```
  neliveplayer_core: ^1.0.0-rc.0
 ```

### step 2,add NeLivePlayerView in your widget tree

```
body: Stack(
          children: [
            NeLivePlayerView(
            //object of NeLivePlayer for control player
              player: player,
            ),
          ],
        ),
```

## Usage

please check player_page.dart and player_page_second.dart in example

