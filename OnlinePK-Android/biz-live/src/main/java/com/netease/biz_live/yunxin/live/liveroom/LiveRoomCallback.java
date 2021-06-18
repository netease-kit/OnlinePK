/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom;

/**
 * 直播间通用回调
 */
public abstract class LiveRoomCallback<T> {

    public void onSuccess(T parameter){
        if(parameter == null){
            onSuccess();
        }
    }

    protected void onSuccess(){

    }

    public abstract void onError(int code, String msg);
}
