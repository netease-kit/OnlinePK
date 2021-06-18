/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom;

import android.content.Context;

import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.lava.nertc.sdk.video.NERtcVideoCallback;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;

/**
 * 直播间抽象类
 */
public abstract class NERTCLiveRoom {

    public static NERTCLiveRoom sharedInstance(boolean isAnchor) {
        if(isAnchor) {
            return NERTCAnchorLiveRoom.sharedInstance();
        }else {
            return NERTCAudienceLiveRoom.sharedInstance();
        }
    }


    /**
     * 结束直播后调用
     */
    public static void destroySharedInstance(boolean isAnchor) {
        if(isAnchor) {
            NERTCAnchorLiveRoom.destroySharedInstance();
        }else {
            NERTCAudienceLiveRoom.destroySharedInstance();
        }
    }

    /**
     * 初始化，每场直播只需调用一次
     *
     * @param context
     * @param appKey
     * @param option
     */
    public abstract void init(Context context, String appKey,
                              NERtcOption option);

    /**
     * 设置远端的视频接受播放器
     *
     * @param videoRender
     * @param uid
     */
    public abstract void setupRemoteView(NERtcVideoView videoRender, long uid, boolean isTop);


    /**
     * 设置本端的视频接受播放器
     *
     * @param videoRender
     */
    public abstract void setupLocalView(NERtcVideoView videoRender);

    /**
     * 设置视频callback，用于美颜
     *
     * @param callback
     * @param needI420 是否需要同时返回YUVI420的数据（该操作会有一定耗时，只有在第三方滤镜库要求一定要yuv数据时才需要打开）
     */
    public abstract void setVideoCallback(NERtcVideoCallback callback, boolean needI420);

    /**
     * 加入rtc房间，在获取checkSum 之后调用
     *
     * @param checkSum
     * @param channelName
     * @param uid
     * @param roomCid     音视频房间标识
     */
    public abstract void joinRtcChannel(String checkSum, String channelName, long uid, String roomCid);

    /**
     * 切换摄像头
     */
    public abstract boolean switchCamera();

    /**
     * 是否打开摄像头
     *
     * @param enable
     * @return
     */
    public abstract boolean enableLocalVideo(boolean enable);

    /**
     * 是否打开麦克风
     *
     * @param isMute
     * @return
     */
    public abstract boolean muteLocalAudio(boolean isMute);

    /**
     * 打开关闭耳返
     *
     * @param enable
     * @param volume
     * @return
     */
    public abstract boolean enableEarback(boolean enable, int volume);

    /**
     * 获取服务，如PK
     * @param tClass
     * @param <T>
     * @return
     */
    public abstract  <T> T getService(Class<T> tClass);

}
