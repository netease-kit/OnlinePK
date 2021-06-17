package com.netease.biz_live.yunxin.live.liveroom;

import com.netease.biz_live.yunxin.live.liveroom.impl.NERTCAnchorBaseLiveRoomImpl;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioEffectOption;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioMixingOption;
import com.netease.lava.nertc.sdk.video.NERtcVideoCallback;
import com.netease.lava.nertc.sdk.video.NERtcVideoConfig;

/**
 * 直播间抽象类
 */
public abstract class NERTCAnchorLiveRoom extends NERTCLiveRoom{

    public static NERTCAnchorLiveRoom sharedInstance() {
        return NERTCAnchorBaseLiveRoomImpl.sharedInstance();
    }


    /**
     * 设置组件回调接口
     * <p>
     * 您可以通过 NERTCLiveRoomDelegate 获得 NERTCLiveRoom 的各种状态通知
     *
     * @param delegate 回调接口
     */
    public abstract void setDelegate(NERTCAnchorBaseLiveRoomDelegate delegate);

    /**
     * 结束直播后调用
     */
    public static void destroySharedInstance() {
        NERTCAnchorBaseLiveRoomImpl.destroySharedInstance();
    }



    /**
     * 创建直播间（主播端调用）
     *
     * @param liveInfo       单主播直播间信息
     * @param profile        分辨率
     * @param frameRate      码率
     * @param mAudioScenario 音频
     * @param callback
     * @param isFrontCam     是否前置摄像头
     */
    public abstract void createRoom(LiveInfo liveInfo,
                                    int profile, NERtcVideoConfig.NERtcVideoFrameRate frameRate,
                                    int mAudioScenario,
                                    boolean isFrontCam,
                                    LiveRoomCallback callback);


    /**
     * 结束直播
     */
    public abstract void stopLive();

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
     * 开始预览
     */
    public abstract void startVideoPreview();

    /**
     * 停止预览
     */
    public abstract void stopVideoPreview();

    /**
     * 结束混音
     */
    public abstract void stopAudioMixing();

    /**
     * 设置混音发送音量
     *
     * @param progress
     */
    public abstract void setAudioMixingSendVolume(int progress);

    /**
     * 设置混音耳返音量
     *
     * @param progress
     */
    public abstract void setAudioMixingPlaybackVolume(int progress);

    /**
     * 设置伴音音量
     *
     * @param id
     * @param volume
     */
    public abstract void setEffectSendVolume(int id, int volume);

    /**
     * 设置伴音耳返音量
     *
     * @param id
     * @param volume
     */
    public abstract void setEffectPlaybackVolume(int id, int volume);

    /**
     * 停止伴音
     *
     * @param id
     * @return
     */
    public abstract int stopEffect(int id);

    /**
     * 开始伴音
     *
     * @param id
     * @param option
     * @return
     */
    public abstract int playEffect(int id, NERtcCreateAudioEffectOption option);

    /**
     * 开始混音
     *
     * @param option
     * @return
     */
    public abstract int startAudioMixing(NERtcCreateAudioMixingOption option);

    /**
     * 停止所有伴音
     */
    public abstract void stopAllEffects();
}
