package com.netease.biz_live.yunxin.live.floatplay

import com.netease.yunxin.kit.alog.ALog

object AudienceDataManager {
    private var roomId=""
    private var data:AudienceData?=null
    private val TAG="AudienceDataManager"
    fun setRoomId(roomId:String){
        this.roomId=roomId
    }

    fun getRoomId():String{
        return roomId
    }

    fun setDataToCache(data:AudienceData){
        this.data=data
    }

    fun getDataFromCache():AudienceData?{
        return data
    }

    fun hasCache(roomId: String):Boolean{
        return roomId == getRoomId() && getDataFromCache() != null
                &&roomId==getDataFromCache()?.liveInfo?.live?.roomId
    }

    fun clear(){
        roomId=""
        data=null
        ALog.d(TAG,"clear()")
    }
}