// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/anchor/start_live_arguments.dart';
import 'package:livekit_pk/audience/option/live_options.dart';
import 'package:livekit_pk/utils/toast_utils.dart';
import 'package:livekit_pk/widgets/live_list.dart';
import 'package:livekit_pk/values/asset_name.dart';

import '../main.dart';
import '../values/strings.dart';
import 'live_footer.dart';
import 'live_header.dart';
import '../nav/nav_utils.dart';
import '../nav/router_name.dart';

class LiveListPage extends StatefulWidget {
  const LiveListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LiveListPageState();
  }
}

class _LiveListPageState extends State<LiveListPage> with RouteAware, LiveListDataMixin {

  late EasyRefreshController _controller;

  void _loadDataCallback(List<NELiveDetail> liveInfoList, bool isRefresh) {
    if(mounted) {
      setState(() {
        setDataList(liveInfoList, isRefresh);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
    loadData();
  }

  void loadData() {
    getLiveLists(true, _loadDataCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xff1a1a24), Color(0xff12121a)]),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => {Navigator.of(context).pop(true)}),
          title: const Text('PK Live'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Stack(alignment: Alignment.bottomRight, children: [
          EasyRefresh(
              controller: _controller,
              header: LiveListHeader(),
              footer: LiveListFooter(),
              child: GridView.count(
                //Horizontal spacing between child widgets
                crossAxisSpacing: 8.0,
                //Vertical spacing between child widgets
                mainAxisSpacing: 8.0,
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: LiveConfig.defaultGridSide,
                childAspectRatio: 1.0,
                children: getWidgetList(),
              ),
              onRefresh: () async{
                nextPageNum = 1;
                getLiveLists(true, _loadDataCallback);
              },
              onLoad: () async {
                if(haveMore) {
                  getLiveLists(false, _loadDataCallback);
                } else {
                  _controller.finishLoad(success: true, noMore: true);
                }
              },
            emptyWidget: liveList.length == 0
                ? SizedBox(
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(
                          child: SizedBox(),
                          flex: 2,
                        ),
                        SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: Image.asset('assets/images/3.0x/icon_empty.png'),
                        ),
                        const Text(
                          Strings.emptyLive,
                          style: TextStyle(
                              fontSize: 14.0, color: Color(0xff505065)),
                        ),
                        const Expanded(
                          child: SizedBox(),
                          flex: 3,
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          GestureDetector(
            child: Container(
                margin: const EdgeInsets.only(right: 5, bottom: 20),
                width: 120,
                height: 120,
                child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Image.asset(
                        'assets/images/3.0x/icon_live_start.png',
                        width: 120,
                        height: 120,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 25),
                            child: Image.asset(
                              AssetName.iconLive,
                              width: 30,
                              height: 30,
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: const Text(
                                Strings.startLive,
                                style:TextStyle(color: Colors.white, fontSize: 13),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
            onTap: () {
              NavUtils.pushNamed(context, RouterName.startLivePage).then((value) {
                if(value is StartLiveArguments && value.result == StartLiveResult.noPermission){
                  ToastUtils.showToast(context, Strings.biz_live_authorization_failed);
                }
                loadData();
              });
            },
          )
        ]),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  /// RouteAware
  @override
  void didPush() {
  }

  @override
  void didPopNext() {
    loadData();
    // Covering route was popped off the navigator.
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
    _controller.dispose();
  }

  List<Widget> getWidgetList() {
    return liveList.map((item) => getItemContainer(item)).toList();
  }

  Widget getItemContainer(NELiveDetail item) {
    var itemWidth = (MediaQuery.of(context).size.width - 8.0 * 3) / 2;
    return GestureDetector(
      onTap: () {
        NavUtils.pushNamed(context, RouterName.liveAudiencePage,
            arguments: {'item': item, 'liveList': liveList}).then((value) => {
          loadData()
        });
      },
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Visibility(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: FittedBox(
                child: Image.network(
                  item.live?.cover == null ? "" : item.live!.cover!,
                  alignment: Alignment.center,
                  width: itemWidth,
                  height: itemWidth,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            visible: item.live?.cover != null,
          ),
          Container(
            margin: const EdgeInsets.only(left: 8, top: 8),
            width: 100,
            height: 24,
            child: Visibility(
                visible: item.live?.live == NELiveStatus.pking ||
                    item.live?.live == NELiveStatus.punishing ||
                    item.live?.live == NELiveStatus.connected,
                child: Image.asset(item.live?.live == NELiveStatus.pking ||
                        item.live?.live == NELiveStatus.punishing
                    ? AssetName.iconPK
                    : AssetName.iconPKConnected)),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            margin: const EdgeInsets.only(left: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  margin: const EdgeInsets.only(left: 0, bottom: 4),
                  child: Text(
                    item.live?.liveTopic == null ? "": item.live!.liveTopic!,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    item.anchor?.userName == null ? "": item.anchor!.userName!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            child: Text(
              item.live == null ? "0": item.live!.audienceCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  showTip(String? msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? ''),
      ),
    );
  }
}
