package com.netease.biz_live.yunxin.live.floatplay

import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_live_room_service.bean.LiveUser
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg

class AudienceData {
    /**
     * 直播间列表数据，维护小窗切大窗时的上下切换逻辑
     */
    var infoList =ArrayList<LiveInfo>()

    /**
     * 当前直播间在列表的位置，维护小窗切大窗时的上下切换逻辑
     */
    var currentPosition =-1

    var liveInfo: LiveInfo? = null

    val chatRoomMsgList = ArrayList<CharSequence>()

    var userCount=0
    var rewardTotal=0L
    var userList:MutableList<LiveUser>?=null
    var videoInfo:VideoInfo?=null

    init {
        videoInfo=VideoInfo()
    }

    class VideoInfo{
        var videoWidth=0
        var videoHeight=0
    }

    override fun toString(): String {
        return "AudienceData(infoList=$infoList, currentPosition=$currentPosition, liveInfo=$liveInfo, chatRoomMsgList=$chatRoomMsgList, userCount=$userCount, rewardTotal=$rewardTotal, userList=$userList, videoInfo=$videoInfo)"
    }

}