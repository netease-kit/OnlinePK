/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.network;


import com.netease.biz_live.yunxin.live.constant.AudioActionType;
import com.netease.biz_live.yunxin.live.constant.VideoActionType;
import com.netease.biz_live.yunxin.live.model.response.SeatsResponse;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
import com.netease.yunxin.android.lib.network.common.transform.ErrorTransform;

import java.util.HashMap;
import java.util.Map;

import io.reactivex.Single;

/**
 * @author sunkeding
 * 麦位管理网络访问交互
 */
public class SeatsManagerInteraction {

    /**
     * 操作麦位
     *
     * @param roomId 房间roomCid
     * @param userId 用户账号
     * @param action {@link com.netease.biz_live.yunxin.live.constant.SeatsActionType}
     */
    public static Single<BaseResponse<Boolean>> operateSeats(String roomId, String userId, int action) {
        SeatsManagerServerApi serverApi = NetworkClient.getInstance().getService(SeatsManagerServerApi.class);
        Map<String, Object> map = new HashMap<>();
        map.put("action", action);
        return serverApi.operateSeats(roomId, userId, map).compose(new ErrorTransform<>())
                .map(res -> res);
    }

    /**
     * 获取观众列表
     *
     * @param roomId
     * @param type
     * @return
     */
    public static Single<BaseResponse<SeatsResponse>> getAudienceList(String roomId, int type) {
        SeatsManagerServerApi api = NetworkClient.getInstance().getService(SeatsManagerServerApi.class);
        return api.getAudienceList(roomId, type)
                .compose(new ErrorTransform<>())
                .map(seatsResponseBaseResponse -> seatsResponseBaseResponse);
    }

    /**
     * @param roomId
     * @param action
     * @return
     */
    public static Single<BaseResponse<Boolean>> enableSeat(String roomId, int action) {
        SeatsManagerServerApi api = NetworkClient.getInstance().getService(SeatsManagerServerApi.class);
        Map<String, Object> map = new HashMap<>();
        map.put("action", action);
        return api.enableSeat(roomId, map)
                .compose(new ErrorTransform<>())
                .map(booleanBaseResponse -> booleanBaseResponse);
    }


    /**
     * 麦位音视频操作
     *
     * @param roomId 房间roomCid
     * @param userId 用户账号
     * @param video  视频开关： {@link com.netease.biz_live.yunxin.live.constant.VideoActionType}
     * @param audio  音频开关： {@link com.netease.biz_live.yunxin.live.constant.AudioActionType}
     */
    public static Single<BaseResponse<Boolean>> changeSeatAV(String roomId, String userId, int video, int audio) {
        SeatsManagerServerApi serverApi = NetworkClient.getInstance().getService(SeatsManagerServerApi.class);
        Map<String, Object> map = new HashMap<>();
        if (VideoActionType.DEFAULT!=video){
            map.put("video", video);
        }
        if (AudioActionType.DEFAULT!=audio){
            map.put("audio", audio);
        }
        return serverApi.changeSeatAV(roomId, userId, map).compose(new ErrorTransform<>())
                .map(res -> res);
    }
}
