package com.netease.yunxin.lib_live_room_service

object LiveTypeManager {
    private var currentLiveType=Constants.LiveType.LIVE_TYPE_DEFAULT

    fun setCurrentLiveType(currentLiveType:Int){
        this.currentLiveType=currentLiveType
    }
    fun getCurrentLiveType():Int{
        return currentLiveType
    }
}