// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';

import '../values/strings.dart';

class CheckNetworkWidget extends StatefulWidget {
  const CheckNetworkWidget({Key? key}) : super(key: key);

  @override
  State<CheckNetworkWidget> createState() => _CheckNetworkWidgetState();
}

class _CheckNetworkWidgetState extends State<CheckNetworkWidget> {
  late NELiveCallback _callback;

  NERoomRtcNetworkStatusType _quality =
      NERoomRtcNetworkStatusType.kStatusUnknown;

  NERoomRtcLastmileProbeResult? _result;

  bool _getResult = false;

  @override
  void initState() {
    super.initState();

    _callback = NELiveCallback(
      rtcLastmileProbeResult: (rtcLastmileProbeResult) {
        setState(() {
          _result = rtcLastmileProbeResult;
          _getResult = true;
        });
      },
      rtcLastmileQuality: (rtcLastmileQuality) {
        setState(() {
          _quality = rtcLastmileQuality;
        });
      },
    );
    NELiveKit.instance.addEventCallback(_callback);
    NELiveKit.instance.mediaController
        .startLastmileProbeTest(NERoomRtcLastmileProbeConfig(
      probeUplink: true,
      probeDownlink: true,
      expectedUplinkBitrate: 2000000,
      expectedDownlinkBitrate: 2000000,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 299,
      child: Column(
        children: <Widget>[
          Container(
            height: 10,
          ),
          const SizedBox(
            height: 48,
            child: Text(
              Strings.checkNetwork,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 20,
          ),
          Text(_getQuality()),
          Container(
            height: 20,
          ),
          Visibility(
              visible: !_getResult,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    child: CircularProgressIndicator(),
                    height: 20,
                    width: 20,
                  ),
                  Container(
                    height: 20,
                  ),
                ],
              )),
          Text(_getResultContent()),
        ],
      ),
    );
  }

  String _getQuality() {
    switch (_quality) {
      case NERoomRtcNetworkStatusType.kStatusUnknown:
        return Strings.networkUnknown;
      case NERoomRtcNetworkStatusType.kStatusExcellent:
        return Strings.networkExcellent;
      case NERoomRtcNetworkStatusType.kStatusGood:
        return Strings.networkGood;
      case NERoomRtcNetworkStatusType.kStatusPoor:
        return Strings.networkPoor;
      case NERoomRtcNetworkStatusType.kStatusBad:
        return Strings.networkBad;
      case NERoomRtcNetworkStatusType.kStatusVeryBad:
        return Strings.networkVeryBad;
      case NERoomRtcNetworkStatusType.kStatusDown:
        return Strings.networkDown;
    }
  }

  String _getResultContent() {
    if (_result != null) {
      final rtt = _result?.rtt.toString();
      final state = _result?.state;
      final downLossRate = _result?.downlinkReport?.packetLossRate.toString();
      final downAvailableBandwidth =
          _result?.downlinkReport?.availableBandwidth.toString();
      final downJitter = _result?.downlinkReport?.jitter.toString();
      final upLossRate = _result?.uplinkReport?.packetLossRate.toString();
      final upAvailableBandwidth =
          _result?.uplinkReport?.availableBandwidth.toString();
      final upJitter = _result?.uplinkReport?.jitter.toString();

      var str = "";
      if (rtt != null) {
        str = str + 'rtt: ' + rtt + '\r\n';
      }
      if (state != null) {
        switch (state) {
          case NERoomRtcLastmileProbeResultState.kUnavailable:
            str = str + 'state: ' + 'Unavailable' + '\r\n';
            break;
          case NERoomRtcLastmileProbeResultState.kComplete:
            str = str + 'state: ' + 'Complete' + '\r\n';
            break;
          case NERoomRtcLastmileProbeResultState.kIncompleteNoBwe:
            str = str + 'state: ' + 'Incomplete No Bwe' + '\r\n';
            break;
        }
      }
      if (downLossRate != null) {
        str = str + 'down lossRate: ' + downLossRate + '\r\n';
      }
      if (downAvailableBandwidth != null) {
        str =
            str + 'down availableBandwidth: ' + downAvailableBandwidth + '\r\n';
      }
      if (downJitter != null) {
        str = str + 'down jitter: ' + downJitter + '\r\n';
      }
      if (upLossRate != null) {
        str = str + 'up lossRate: ' + upLossRate + '\r\n';
      }
      if (upAvailableBandwidth != null) {
        str = str + 'up availableBandwidth: ' + upAvailableBandwidth + '\r\n';
      }
      if (upJitter != null) {
        str = str + 'up jitter: ' + upJitter + '\r\n';
      }
      return str;
    }
    return Strings.checkNetworkInProgress;
  }

  @override
  void dispose() {
    super.dispose();
    NELiveKit.instance.removeEventCallback(_callback);
    NELiveKit.instance.mediaController.stopLastmileProbeTest();
  }
}
