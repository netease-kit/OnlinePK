package com.netease.biz_live.yunxin.live.network;


import com.netease.biz_live.yunxin.live.model.response.SeatsResponse;
import com.netease.yunxin.android.lib.network.common.BaseResponse;


import java.util.Map;

import io.reactivex.Single;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Path;

/**
 * @author sunkeding
 * 麦位管理API
 */
public interface SeatsManagerServerApi {

    /**
     * 麦位操作
     */
    @POST("/room/{roomId}/user/{userId}/seats")
    Single<BaseResponse<Boolean>> operateSeats(@Path("roomId") String roomId,@Path("userId") String userId, @Body Map<String, Object> map);

    /**
     * 获取观众列表
     * @param roomId
     * @param type
     * @return
     */
    @GET("/room/{roomId}/seat/{type}/list")
    Single<BaseResponse<SeatsResponse>> getAudienceList(@Path("roomId") String roomId, @Path("type") int type);

    /**
     * 麦位屏蔽/取消屏蔽
     * @param roomId
     * @param map
     * @return
     */
    @POST("/room/{roomId}/seat")
    Single<BaseResponse<Boolean>> enableSeat(@Path("roomId") String roomId,@Body Map<String, Object> map);

    /**
     * 麦位音视频操作
     * @param roomId
     * @param map
     * @return
     */
    @POST("/room/{roomId}/user/{userId}/change")
    Single<BaseResponse<Boolean>> changeSeatAV(@Path("roomId") String roomId,@Path("userId") String userId,@Body Map<String, Object> map);
}
