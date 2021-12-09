/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.bean

import java.io.Serializable

data class LiveMsg(
    val roomId: String,//房间编号
    val roomTopic: String,// 房间主题
    val type: Int,//	房间类型
    val status: Int,//	房间状态
    val liveStatus: Int,//	直播状态
    val cover: String,// 背景图地址
    val roomCid: String,//	音视频房间编号
    val roomCname: String,//音视频房间名
    val chatRoomId: String,//	聊天室编号
    val chatRoomCreator: String,//	聊天室创建人编号
    val audienceCount: Int,//	观众人数
    val liveConfig: LiveConfig,//	直播配置
    val rewardTotal: Long//	打赏总额
) : Serializable {
    override fun toString(): String {
        return "LiveMsg(roomId='$roomId', roomTopic='$roomTopic', type=$type, status=$status, liveStatus=$liveStatus, cover='$cover', roomCid='$roomCid', roomCname='$roomCname', chatRoomId='$chatRoomId', chatRoomCreator='$chatRoomCreator', audienceCount=$audienceCount, liveConfig=$liveConfig, rewardTotal=$rewardTotal)"
    }
}