/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.audience.ui.view;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.NetworkUtils;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.SizeUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_live.R;
import com.netease.biz_live.databinding.ViewIncludeRoomTopBinding;
import com.netease.biz_live.databinding.ViewItemAudienceLiveRoomInfoBinding;
import com.netease.biz_live.yunxin.live.audience.callback.SeatApplyAcceptEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatApplyRejectEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatMuteStateChangeEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatCustomInfoChangeEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatEnterEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatKickedEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatLeaveEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatPickRequestEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatVideoOpenStateChangeEvent;
import com.netease.biz_live.yunxin.live.audience.ui.dialog.GiftDialog;
import com.netease.biz_live.yunxin.live.audience.ui.dialog.LinkSeatsStatusDialog;
import com.netease.biz_live.yunxin.live.audience.utils.AccountUtil;
import com.netease.biz_live.yunxin.live.audience.utils.AudienceDialogControl;
import com.netease.biz_live.yunxin.live.audience.utils.AudiencePKControl;
import com.netease.biz_live.yunxin.live.audience.utils.DialogHelperActivity;
import com.netease.biz_live.yunxin.live.audience.utils.InputUtils;
import com.netease.biz_live.yunxin.live.audience.utils.LinkedSeatsAudienceActionManager;
import com.netease.biz_live.yunxin.live.audience.utils.StringUtils;
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator;
import com.netease.biz_live.yunxin.live.chatroom.control.Audience;
import com.netease.biz_live.yunxin.live.chatroom.control.ChatRoomNotify;
import com.netease.biz_live.yunxin.live.chatroom.control.SkeletonChatRoomNotify;
import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PkStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.LiveChatRoomInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RewardGiftInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RoomMsg;
import com.netease.biz_live.yunxin.live.constant.ApiErrorCode;
import com.netease.biz_live.yunxin.live.constant.AudioActionType;
import com.netease.biz_live.yunxin.live.constant.ErrorCode;
import com.netease.biz_live.yunxin.live.constant.LiveStatus;
import com.netease.biz_live.yunxin.live.constant.VideoActionType;
import com.netease.biz_live.yunxin.live.gift.GiftCache;
import com.netease.biz_live.yunxin.live.gift.GiftRender;
import com.netease.biz_live.yunxin.live.gift.ui.GifAnimationView;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAudienceLiveRoom;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAudienceLiveRoomDelegate;
import com.netease.biz_live.yunxin.live.liveroom.impl.NERTCAudienceLiveRoomImpl;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;
import com.netease.biz_live.yunxin.live.model.response.AnchorQueryInfo;
import com.netease.biz_live.yunxin.live.model.response.PkRecord;
import com.netease.biz_live.yunxin.live.network.LiveInteraction;
import com.netease.biz_live.yunxin.live.network.LiveServerApi;
import com.netease.biz_live.yunxin.live.ui.widget.LinkSeatsAudienceRecycleView;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.demo.utils.SpUtils;
import com.netease.yunxin.nertc.demo.utils.ViewUtils;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.List;

import io.reactivex.observers.ResourceSingleObserver;

/**
 * Created by luc on 2020/11/19.
 * <p>
 * 观众端详细控制，继承自{@link FrameLayout} 添加了 {@link TextureView} 以及 {@link ExtraTransparentView} 作为页面主要元素
 * <p>
 * TextureView 用于页面视频播放；
 * <p>
 * ExtraTransparentView 用于页面信息展示，由于页面存在左右横滑状态所以自定义view 继承自 {@link RecyclerView} 用于页面左右横滑支持；
 // * 实际页面布局见 R.layout.view_item_audience_live_room_info
 *
 * <p>
 * 此处 {@link #prepare(),#release()} 方法依赖于recyclerView 子 view 的 {@link androidx.recyclerview.widget.RecyclerView#onChildAttachedToWindow(View)},
 * {@link androidx.recyclerview.widget.RecyclerView#onChildDetachedFromWindow(View)} 方法，
 * 方法，{@link #renderData(LiveInfo)} 依赖于 {@link androidx.recyclerview.widget.RecyclerView.Adapter#onBindViewHolder(RecyclerView.ViewHolder, int)}
 * 此处使用 {@link androidx.recyclerview.widget.LinearLayoutManager} 从源码角度可以保障 renderData 调用时机早于 prepare 时机。
 *
 */
@SuppressLint("ViewConstructor")
public class AudienceContentView extends FrameLayout{
    private static final String TAG = AudienceContentView.class.getSimpleName();
    /**
     * 用户服务
     */
    private final UserCenterService userCenterService = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
    /**
     * 页面 View 所在 activity
     */
    private final BaseActivity activity;
    /**
     * 观众端聊天室相关控制
     */
    private final Audience audienceControl = Audience.getInstance();

    /**
     * 礼物渲染控制，完成礼物动画的播放，停止，顺序播放等
     */
    private final GiftRender giftRender = new GiftRender();
    /**
     * 直播播放View
     */
    private CDNStreamTextureView videoView;
    /**
     * 当自己是连麦观众时，需要播放主播的RTC流
     */
    private NERtcVideoView rtcVideoView;

    /**
     * 信息浮层左右切换
     */
    private ExtraTransparentView horSwitchView;
    /**
     * 观众端信息浮层，viewbinding 官方文档:https://developer.android.com/topic/libraries/view-binding?hl=zh-cn#java
     */
    private ViewItemAudienceLiveRoomInfoBinding infoBinding;
    private ViewIncludeRoomTopBinding includeRoomTopBinding;
    /**
     * 直播间详细信息
     */
    private LiveInfo liveInfo;

    /**
     * pk 状态整体控制
     */
    private AudiencePKControl audiencePKControl;
    //
//    /**
//     * 主播错误状态展示（包含结束直播）
//     */
    private AudienceErrorStateView errorStateView;

    /**
     * 等待主播接受连麦申请的浮层
     */
    private WaitAnchorAcceptView waitAnchorAcceptFloatLayer;

    /**
     * 礼物弹窗
     */
    private GiftDialog giftDialog;

    /**
     * 依赖对象中回调，{@link #prepare()} 状态设置为 true；
     * {@link #release()} 状态设置为 false;
     */
    private boolean canRender;

    /**
     * 观众端连麦管理
     */
    private LinkedSeatsAudienceActionManager linkedSeatsAudienceActionManager;
    /**
     * 弹窗控制
     */
    private AudienceDialogControl audienceDialogControl;
    /**
     * 右边的连麦观众列表，如果自己也是连麦观众，需要把自己放首位
     * 有人上麦就添加，有人下麦就移除，默认隐藏，展示RTC画面就把linkSeatsRv显示出来，确保不会因为isLinkingSeats刷新过程中有人上麦导致的UI显示异常问题
     */
    private LinkSeatsAudienceRecycleView linkSeatsRv;
    /**
     * 是否正在连麦，连麦的话需要展示主播的RTC流，否则的话展示主播的CDN流
     */
    private boolean isLinkingSeats = false;
    private boolean isPking = false;
    private boolean isFirstShowNormalUI=true;
    private boolean joinRoomSuccess=false;
    /**
     * 监听网络状态
     */
    private NetworkUtils.OnNetworkStatusChangedListener onNetworkStatusChangedListener = new NetworkUtils.OnNetworkStatusChangedListener() {
        @Override
        public void onDisconnected() {
            ToastUtils.showLong(R.string.biz_live_network_error);
            ALog.d(TAG,"onDisconnected():"+System.currentTimeMillis());
            showCurrentUI(false,false);
            changeErrorState(true, AudienceErrorStateView.TYPE_ERROR);
            linkedSeatsAudienceActionManager.dismissAllDialog();
            if (giftDialog!=null&&giftDialog.isShowing()){
                giftDialog.dismiss();
            }
        }

        @Override
        public void onConnected(NetworkUtils.NetworkType networkType) {
            ALog.d(TAG,"onConnected():"+System.currentTimeMillis());
            if (canRender && liveInfo != null) {
                initForLiveType(true);
            }
        }
    };

    private NERTCAudienceLiveRoomDelegate seatCallback =new NERTCAudienceLiveRoomDelegate() {
        @Override
        public void onError(boolean serious, int code, String msg) {
            ALog.d(TAG,"onError serious:"+serious+",code:"+code+",msg:"+msg);
            if (serious){
                if (!activity.isFinishing()){
                    activity.finish();
                }
            }else {
                if (!isNetworkConnected(activity)&&ErrorCode.ERROR_CODE_DISCONNECT==code&&!activity.isFinishing()){
                    activity.finish();
                    return;
                }
                if (!TextUtils.isEmpty(msg)){
                    ToastUtils.showShort(msg);
                }
            }
        }

        @Override
        public void onSeatEntered(SeatEnterEvent event) {
            ALog.d(TAG,"onSeatEntered ");
            if (isPking){
                if (AccountUtil.isCurrentUser(event.member.accountId)){
                    linkedSeatsAudienceActionManager.leaveSeat(liveInfo.liveCid, new LiveRoomCallback<Void>() {
                        @Override
                        public void onError(int code, String msg) {
                            ToastUtils.showShort(msg);
                        }
                    });
                }
                showCurrentUI(false,true);
                return;
            }
            if (event.member==null){
                return;
            }
            if (AccountUtil.isCurrentUser(event.member.accountId)){
                //设置本次连麦的开始时间戳
                DurationStatisticTimer.DurationUtil.setBeginTimeStamp(System.currentTimeMillis());
                showCurrentUI(true,false);
            }else {
                linkSeatsRv.appendItem(event.member);
                if (!isLinkingSeats){
                    videoView.setLinkingSeats(true);
                }
            }
            infoBinding.crvMsgList.appendItem(ChatRoomMsgCreator.createSeatEnter(event.member.nickName));
        }

        @Override
        public void onSeatLeft(SeatLeaveEvent event) {
            ALog.d(TAG,"onSeatLeft ");
            if (event.member==null){
                return;
            }
            if (AccountUtil.isCurrentUser(event.member.accountId)){
                showCurrentUI(false,true);
            }
            linkSeatsRv.remove(event.member);
            infoBinding.crvMsgList.appendItem(ChatRoomMsgCreator.createSeatExit(event.member.nickName));
            if (!isLinkingSeats){
                videoView.setLinkingSeats(linkSeatsRv.haveMemberInSeats()&&!linkSeatsRv.contains(userCenterService.getCurrentUser().accountId));
            }
        }

        @Override
        public void onSeatKicked(SeatKickedEvent event) {
            ALog.d(TAG,"onSeatKicked ");
            ToastUtils.showShort(activity.getString(R.string.biz_live_anchor_kick_audience));
            showCurrentUI(false,true);
            linkedSeatsAudienceActionManager.onDestory();
        }

        /**
         * 收到主播的报麦申请
         */
        @Override
        public void onSeatPickRequest(SeatPickRequestEvent event) {
            ALog.d(TAG,"onSeatPickRequest ");
            getAudienceDialogControl().showAnchorInviteDialog(activity, new AudienceDialogControl.JoinSeatsListener() {
                @Override
                public void acceptInvite() {
                    ALog.d(TAG,"接受主播的连麦邀请");
                    linkedSeatsAudienceActionManager.acceptSeatPick(liveInfo.liveCid, userCenterService.getCurrentUser().accountId, new LiveRoomCallback<Void>() {
                        @Override
                        public void onSuccess(Void parameter) {
                            super.onSuccess(parameter);
                            final String[] permissions = new String[]{Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO};
                            PermissionUtils.permission(permissions).callback(new PermissionUtils.FullCallback() {
                                @Override
                                public void onGranted(@NonNull List<String> granted) {
                                    joinRtcAndShowRtcUI(event.member);
                                }

                                @Override
                                public void onDenied(@NonNull List<String> deniedForever, @NonNull List<String> denied) {
                                    ToastUtils.showShort(activity.getString(R.string.biz_live_permission_error_tips));
                                    joinRtcAndShowRtcUI(event.member);
                                }
                            }).request();
                        }

                        @Override
                        public void onError(int code, String msg) {
                            ALog.d(TAG,"acceptSeatPick onError:"+msg);
                            ToastUtils.showShort(msg);
                        }
                    });

                }

                @Override
                public void rejectInvite() {
                    ALog.d(TAG,"拒绝主播的连麦邀请");
                    linkedSeatsAudienceActionManager.rejectSeatPick(liveInfo.liveCid, userCenterService.getCurrentUser().accountId, new LiveRoomCallback<Void>() {
                        @Override
                        public void onSuccess(Void parameter) {
                            super.onSuccess(parameter);
                            ToastUtils.showShort("您已成功拒绝了主播的连麦邀请");
                        }

                        @Override
                        public void onError(int code, String msg) {
                            ALog.d(TAG,"rejectSeatPick onError:"+msg);
                            ToastUtils.showShort(msg);
                        }
                    });

                }
            });
        }

        /**
         * 申请上麦被同意
         */
        @Override
        public void onSeatApplyAccepted(SeatApplyAcceptEvent event) {
            ALog.d(TAG,"onSeatApplyAccepted");
            final String[] permissions = new String[]{Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO};
            PermissionUtils.permission(permissions).callback(new PermissionUtils.FullCallback() {
                @Override
                public void onGranted(@NonNull List<String> granted) {
                    joinRtcAndShowRtcUI(event.member);
                }

                @Override
                public void onDenied(@NonNull List<String> deniedForever, @NonNull List<String> denied) {
                    ToastUtils.showShort(activity.getString(R.string.biz_live_permission_error_tips));
                    joinRtcAndShowRtcUI(event.member);
                }
            }).request();
        }

        /**
         * 申请上麦被拒绝
         */
        @Override
        public void onSeatApplyRejected(SeatApplyRejectEvent event){
            ALog.d(TAG,"onSeatApplyRejected");
            waitAnchorAcceptFloatLayer.setVisibility(GONE);
            infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE);
            getAudienceDialogControl().showAnchorRejectDialog(activity);
        }

        @Override
        public void onSeatMuteStateChanged(SeatMuteStateChangeEvent event) {
            ALog.d(TAG,"onSeatMuteStateChanged");
            if (AccountUtil.isCurrentUser(event.member.accountId)&&!AccountUtil.isCurrentUser(event.fromUser)){
                //主播端对连麦观众进行了麦位音视频的操作
                if (LinkedSeatsAudienceActionManager.enableLocalVideo&&event.member.video==VideoActionType.CLOSE){
                    ToastUtils.showShort(activity.getString(R.string.biz_live_anchor_close_your_camera));
                    linkedSeatsAudienceActionManager.refreshLinkSeatDialog(LinkSeatsStatusDialog.CAMERA_POSITION,VideoActionType.CLOSE);
                    linkedSeatsAudienceActionManager.enableVideo(false);
                }else if (!LinkedSeatsAudienceActionManager.enableLocalVideo&&event.member.video==VideoActionType.OPEN){
                    ToastUtils.showShort(activity.getString(R.string.biz_live_anchor_open_your_camera));
                    linkedSeatsAudienceActionManager.refreshLinkSeatDialog(LinkSeatsStatusDialog.CAMERA_POSITION,VideoActionType.OPEN);
                    linkedSeatsAudienceActionManager.enableVideo(true);
                }else if (LinkedSeatsAudienceActionManager.enableLocalAudio&&event.member.audio==AudioActionType.CLOSE){
                    ToastUtils.showShort(activity.getString(R.string.biz_live_anchor_close_your_microphone));
                    linkedSeatsAudienceActionManager.refreshLinkSeatDialog(LinkSeatsStatusDialog.MICROPHONE_POSITION,AudioActionType.CLOSE);
                    linkedSeatsAudienceActionManager.enableAudio(false);
                }else if (!LinkedSeatsAudienceActionManager.enableLocalAudio&&event.member.audio==AudioActionType.OPEN){
                    ToastUtils.showShort(activity.getString(R.string.biz_live_anchor_open_your_microphone));
                    linkedSeatsAudienceActionManager.refreshLinkSeatDialog(LinkSeatsStatusDialog.MICROPHONE_POSITION,AudioActionType.OPEN);
                    linkedSeatsAudienceActionManager.enableAudio(true);
                }
                LinkedSeatsAudienceActionManager.enableLocalVideo=(event.member.video==VideoActionType.OPEN);
                LinkedSeatsAudienceActionManager.enableLocalAudio=(event.member.audio==AudioActionType.OPEN);
            }
            linkSeatsRv.updateItem(event.member);
        }


        @Override
        public void onSeatOpenStateChanged(SeatVideoOpenStateChangeEvent event) {
            ALog.d(TAG,"onSeatOpenStateChanged");
        }

        @Override
        public void onSeatCustomInfoChanged(SeatCustomInfoChangeEvent event) {

        }
    };


    private void showCurrentUI(boolean showRtcUI,boolean showCdnUI) {
        isLinkingSeats=showRtcUI;
        if (linkSeatsRv!=null){
            linkSeatsRv.setVisibility(showRtcUI?VISIBLE:GONE);
        }
        if (showRtcUI){
            //添加自己到连麦控件
            addSelfToLinkSeatsRv(userCenterService.getCurrentUser());
            infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.LINK_SEATS_SETTING);
            // 添加RTC流播放
            if (rtcVideoView==null){
                rtcVideoView = new NERtcVideoView(getContext());
                addView(rtcVideoView,0,generateDefaultLayoutParams());
            }
            //设置主播的RTC流画面
            linkedSeatsAudienceActionManager.setupRemoteView(rtcVideoView, liveInfo.avRoomUid);
            rtcVideoView.setVisibility(VISIBLE);
            if (videoView!=null){
                videoView.setVisibility(GONE);
                videoView.reset();
                videoView.release();
            }
            getAudienceDialogControl().dismissAnchorInviteDialog();
        }else {
            infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE);
            if (rtcVideoView!=null){
                rtcVideoView.setVisibility(GONE);
            }
            if (showCdnUI){
                if (videoView==null){
                    videoView=new CDNStreamTextureView(getContext());
                    addView(videoView,0,generateDefaultLayoutParams());
                }
                videoView.setVisibility(VISIBLE);
                // 初始化信息页面位置
                horSwitchView.toSelectedPosition();
                // 播放器控制加载信息
                videoView.prepare(liveInfo);
                // 聊天室信息更新到最新到最新一条
                infoBinding.crvMsgList.toLatestMsg();
            }else {
                if (videoView!=null){
                    videoView.setVisibility(GONE);
                }
            }
        }
        if (waitAnchorAcceptFloatLayer!=null){
            waitAnchorAcceptFloatLayer.setVisibility(GONE);
        }
    }

    /**
     * 聊天室消息回调
     */
    private final ChatRoomNotify roomNotify = new SkeletonChatRoomNotify() {

        @Override
        public void onJoinRoom(boolean success, int code) {
            super.onJoinRoom(success, code);
            joinRoomSuccess=success;
            if (joinRoomSuccess){
                infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE);
            }else {
                infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_DISABLE);
            }
            ALog.e("=====>", "onJoinRoom " + "success " + success + ", code " + code);
        }

        @Override
        public void onMsgArrived(RoomMsg msg) {
            infoBinding.crvMsgList.appendItem(msg.message);
        }

        @Override
        public void onGiftArrived(RewardGiftInfo giftInfo) {
            giftRender.addGift(GiftCache.getGift(giftInfo.giftId).dynamicIconResId);
        }

        @Override
        public void onUserCountChanged(int count) {
            super.onUserCountChanged(count);
            includeRoomTopBinding.tvAudienceCount.setText(StringUtils.getAudienceCount(count));
        }

        @Override
        public void onRoomDestroyed(LiveChatRoomInfo roomInfo) {
            if (!canRender) {
                return;
            }
            changeErrorState(true, AudienceErrorStateView.TYPE_FINISHED);
        }

        @Override
        public void onAnchorLeave() {
            if (!canRender) {
                return;
            }
            changeErrorState(true, AudienceErrorStateView.TYPE_FINISHED);
        }

        @Override
        public void onKickedOut() {
            if (!canRender) {
                return;
            }
            if (activity != null) {
                activity.finish();
                getContext().startActivity(new Intent(getContext(), DialogHelperActivity.class));
            }
        }

        @Override
        public void onAnchorCoinChanged(AnchorCoinChangedAttachment attachment) {
            super.onAnchorCoinChanged(attachment);
            includeRoomTopBinding.tvAnchorCoinCount.setText(StringUtils.getCoinCount(attachment.totalCoinCount));
            getAudiencePKControl().onAnchorCoinChanged(attachment);
        }

        @Override
        public void onPkStatusChanged(PkStatusAttachment pkStatus) {
            super.onPkStatusChanged(pkStatus);
            if (isLinkingSeats){
                 linkedSeatsAudienceActionManager.leaveSeat(liveInfo.liveCid, new LiveRoomCallback<Void>() {
                     @Override
                     public void onError(int code, String msg) {
                         ToastUtils.showShort(msg);
                     }
                 });
                 if (linkSeatsRv.haveMemberInSeats()){
                     for (SeatMemberInfo memberInfo : linkSeatsRv.getMemberList()) {
                          linkSeatsRv.remove(memberInfo);
                     }
                 }
                 showCurrentUI(false,true);
            }
            isPking=true;
            getAudiencePKControl().onPKStatusChanged(pkStatus);
        }

        @Override
        public void onPunishmentStatusChanged(PunishmentStatusAttachment punishmentStatus) {
            getAudiencePKControl().onPunishmentStatusChanged(punishmentStatus);
            if (!punishmentStatus.isStartState()){
                isPking=false;
                showCurrentUI(false,true);
            }
        }

        @Override
        public void onAudienceChanged(List<AudienceInfo> infoList) {
            includeRoomTopBinding.rvAnchorPortraitList.updateAll(infoList);
        }
    };

    /**
     * 错误页面按钮点击响应
     */
    private final AudienceErrorStateView.ClickButtonListener clickButtonListener = new AudienceErrorStateView.ClickButtonListener() {
        @Override
        public void onBackClick(View view) {
            ALog.d(TAG,"onBackClick");
            if (activity != null && !activity.isFinishing()) {
                activity.finish();
            }
        }

        @Override
        public void onRetryClick(View view) {
            ALog.d(TAG,"onRetryClick");
            if (canRender && liveInfo != null) {
                if (joinRoomSuccess){
                    initForLiveType(true);
                }else {
                    select(liveInfo,true);
                }

            }
        }
    };



    public AudienceContentView(@NonNull BaseActivity activity) {
        super(activity);
        this.activity = activity;
        initViews();
    }

    /**
     * 添加并初始化内部子 view
     */
    private void initViews() {
        // 设置 view 背景颜色
        setBackgroundColor(Color.parseColor("#ff201C23"));
        // 添加视频播放 TextureView
        videoView = new CDNStreamTextureView(getContext());
        addView(videoView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        // 添加顶部浮层页
        infoBinding = ViewItemAudienceLiveRoomInfoBinding.inflate(LayoutInflater.from(getContext()),this,false);
        includeRoomTopBinding=ViewIncludeRoomTopBinding.bind(infoBinding.getRoot());
//        infoContentView = LayoutInflater.from(getContext()).inflate(R.layout.view_item_audience_live_room_info, null);
        horSwitchView = new ExtraTransparentView(getContext(), infoBinding.getRoot());
        // 页面左右切换时滑动到最新的消息内容
        horSwitchView.registerSelectedRunnable(() -> {
            infoBinding.crvMsgList.toLatestMsg();
        });
        addView(horSwitchView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        // 浮层信息向下便宜 status bar 高度，避免重叠
        StatusBarConfig.paddingStatusBarHeight(activity, horSwitchView);

        // 添加错误状态浮层
        errorStateView = new AudienceErrorStateView(getContext());
        addView(errorStateView);
        errorStateView.setVisibility(GONE);

        // 添加礼物展示浮层
        // 礼物动画渲染 view
        GifAnimationView gifAnimationView = new GifAnimationView(getContext());
        int size = SpUtils.getScreenWidth(getContext());
        FrameLayout.LayoutParams layoutParams = generateDefaultLayoutParams();
        layoutParams.width = size;
        layoutParams.height = size;
        layoutParams.gravity = Gravity.BOTTOM;
        layoutParams.bottomMargin = SpUtils.dp2pix(getContext(), 166);
        addView(gifAnimationView, layoutParams);
        gifAnimationView.bringToFront();
        // 绑定礼物渲染 view
        giftRender.init(gifAnimationView);

        // 监听软件盘弹起
        InputUtils.registerSoftInputListener(activity, new InputUtils.InputParamHelper() {
            @Override
            public int getHeight() {
                return AudienceContentView.this.getHeight();
            }

            @Override
            public EditText getInputView() {
                return infoBinding.etRoomMsgInput;
            }
        });
    }

    /**
     * 页面信息，拉流，直播间信息展示等
     *
     * @param info 直播间信息
     */
    public void renderData(LiveInfo info) {
        this.liveInfo = info;
        linkedSeatsAudienceActionManager = LinkedSeatsAudienceActionManager.getInstance(activity);
        // 整体页面控件定位并渲染基础信息
        errorStateView.renderInfo(info.avatar, info.nickname);
        videoView.setUp(canRender);
        // 输入聊天框
        infoBinding.etRoomMsgInput.setOnEditorActionListener((v, actionId, event) -> {
            String input = infoBinding.etRoomMsgInput.getText().toString();
            InputUtils.hideSoftInput(infoBinding.etRoomMsgInput);
            audienceControl.sendTextMsg(input);
            return true;
        });
        infoBinding.etRoomMsgInput.setVisibility(GONE);
        // 直播间总人数
        includeRoomTopBinding.tvAudienceCount.setText(StringUtils.getAudienceCount(liveInfo.audienceCount));
        // 主播头像
        ImageLoader.with(getContext().getApplicationContext()).circleLoad(info.avatar, includeRoomTopBinding.ivAnchorPortrait);
        // 主播昵称
        includeRoomTopBinding.tvAnchorNickname.setText(info.nickname);
        // 关闭按钮
        infoBinding.ivRoomClose.setOnClickListener(v -> {
            // 资源释放，页面退出
            activity.finish();
        });

//        // 礼物发送
        infoBinding.ivRoomGift.setOnClickListener(v -> {
            if (giftDialog == null) {
                giftDialog = new GiftDialog(activity);
            }

            giftDialog.show(giftInfo -> {
                RewardGiftInfo rewardGiftInfo = new RewardGiftInfo(liveInfo.liveCid, userCenterService.getCurrentUser().accountId, userCenterService.getCurrentUser().nickname, liveInfo.accountId, giftInfo.giftId);
                LiveInteraction.rewardAnchor(getAudiencePKControl().isPk(), rewardGiftInfo).subscribe(new ResourceSingleObserver<Boolean>() {
                    @Override
                    public void onSuccess(@NonNull Boolean aBoolean) {
                        if (!aBoolean) {
                            ToastUtils.showShort("打赏礼物失败");
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        ToastUtils.showShort("打赏礼物失败");
                    }
                });
            });
        });

        // 显示地步输入栏
        infoBinding.tvRoomMsgInput.setOnClickListener(v -> InputUtils.showSoftInput(infoBinding.etRoomMsgInput));

        //申请连麦or设置推流参数
        infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE);
        infoBinding.btnMultiFunction.setOnButtonClickListener(new MultiFunctionButton.OnButtonClickListener() {
            @Override
            public void applySeat() {
                //按钮置灰
                infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_DISABLE);
                linkedSeatsAudienceActionManager.applySeat(liveInfo.liveCid, new LiveRoomCallback<Void>() {
                    @Override
                    public void onSuccess() {
                        waitAnchorAcceptFloatLayer.setVisibility(VISIBLE);
                    }

                    @Override
                    public void onError(int code, String msg) {
                        if (!TextUtils.isEmpty(msg)){
                            ToastUtils.showShort(msg);
                        }
                        if (ApiErrorCode.HAD_APPLIED_SEAT==code){
                            infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_DISABLE);
                            waitAnchorAcceptFloatLayer.setVisibility(VISIBLE);
                            return;
                        }else if (ApiErrorCode.DONT_APPLY_SEAT==code){
                            waitAnchorAcceptFloatLayer.setVisibility(GONE);
                        }
                        //按钮重新点亮
                        infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE);
                    }
                });
            }

            @Override
            public void showLinkSeatsStatusDialog() {
                linkedSeatsAudienceActionManager.showLinkSeatsStatusDialog(liveInfo);
            }
        });

        linkSeatsRv = new LinkSeatsAudienceRecycleView(getContext());
        FrameLayout.LayoutParams params=  new LayoutParams(SizeUtils.dp2px(88), LayoutParams.WRAP_CONTENT);
        params.topMargin= SizeUtils.dp2px(108);
        params.rightMargin= SizeUtils.dp2px(6);
        params.gravity=Gravity.TOP|Gravity.END;
        addView(linkSeatsRv,params);
        FrameLayout.LayoutParams params2=  new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, SizeUtils.dp2px(44));
        params2.topMargin=SizeUtils.dp2px(108);
        waitAnchorAcceptFloatLayer = new WaitAnchorAcceptView(getContext());
        waitAnchorAcceptFloatLayer.setAudienceLiveRoomDelegate(seatCallback);
        waitAnchorAcceptFloatLayer.setCancelApplySeatClickCallback(new WaitAnchorAcceptView.CancelApplySeatClickCallback() {
            @Override
            public void cancel() {
                infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE);
            }
        });
        addView(waitAnchorAcceptFloatLayer,params2);
        waitAnchorAcceptFloatLayer.setVisibility(GONE);
        waitAnchorAcceptFloatLayer.setLiveInfo(liveInfo);
        linkSeatsRv.setVisibility(GONE);
        linkSeatsRv.setUseScene(LinkSeatsAudienceRecycleView.UseScene.AUDIENCE);
        linkSeatsRv.setLiveInfo(liveInfo);
    }


    /**
     * 页面绑定准备
     */
    public void prepare() {
        showCurrentUI(false,true);
        changeErrorState(false, -1);
        canRender = true;
    }

    /**
     * 页面展示
     */
    public void select(LiveInfo liveInfo,boolean refreshLinkedSeatsUI ) {
        this.liveInfo=liveInfo;
        linkedSeatsAudienceActionManager.setData(seatCallback,liveInfo);
        NERTCAudienceLiveRoomImpl liveRoomImpl= (NERTCAudienceLiveRoomImpl) NERTCAudienceLiveRoom.sharedInstance();
        liveRoomImpl.registerMsgCallback(true);
        // 加入聊天室
        try {
            audienceControl.joinRoom(new LiveChatRoomInfo(liveInfo.chatRoomId, liveInfo.accountId,
                    String.valueOf(liveInfo.roomUid), liveInfo.audienceCount));
        } catch (Exception e) {
            // 加入聊天室出现异常直接退出当前页面
            if (activity != null) {
                activity.finish();
            }
        }
        audienceControl.registerNotify(roomNotify, true);
        // 根据房间当前状态初始化房间信息
        initForLiveType(refreshLinkedSeatsUI);
    }

    /**
     * 页面资源释放
     */
    public void release() {
        if (!canRender) {
            return;
        }
        canRender = false;
        // 播放器资源释放
        videoView.release();
        // 礼物渲染释放
        giftRender.release();
        // 消息列表清空
        infoBinding.crvMsgList.clearAllInfo();
        if (audiencePKControl!=null){
            audiencePKControl.release();
        }
        // 如果是连麦状态，离开RTC房间
        if (isLinkingSeats) {
            ALog.d(TAG,"release:"+liveInfo.toString());
            linkedSeatsAudienceActionManager.leaveSeat(liveInfo.liveCid, new LiveRoomCallback<Void>() {
                @Override
                public void onError(int code, String msg) {
                    ToastUtils.showShort(msg);
                }
            });
            isLinkingSeats=false;
            linkSeatsRv.remove(0);
        }
        linkedSeatsAudienceActionManager.onDestory();
        NERTCAudienceLiveRoomImpl liveRoomImpl= (NERTCAudienceLiveRoomImpl) NERTCAudienceLiveRoom.sharedInstance();
        liveRoomImpl.registerMsgCallback(false);
    }


    private void changeErrorState(boolean error, int type) {
        if (!canRender) {
            return;
        }
        if (error) {
            waitAnchorAcceptFloatLayer.setVisibility(GONE);
            showCurrentUI(false,false);
            videoView.reset();
            if (type == AudienceErrorStateView.TYPE_FINISHED) {
                release();
            } else {
                videoView.release();
            }
        }

        infoBinding.groupNormal.setVisibility(error ? GONE : VISIBLE);
        if (errorStateView != null) {
            errorStateView.setVisibility(error ? VISIBLE : GONE);
        }
        if (error && errorStateView != null) {
            errorStateView.updateType(type, clickButtonListener);
        }
    }

    private void initForLiveType(boolean refreshLinkedSeatsUI) {
        LiveInteraction.queryAnchorRoomInfo(liveInfo.accountId, liveInfo.liveCid)
                .subscribe(new ResourceSingleObserver<BaseResponse<AnchorQueryInfo>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<AnchorQueryInfo> response) {
                        if (!canRender) {
                            return;
                        }
                        if (response.isSuccessful()) {
                            AnchorQueryInfo anchorQueryInfo = response.data;
                            includeRoomTopBinding.tvAnchorCoinCount.setText(StringUtils.getCoinCount(anchorQueryInfo.coinTotal));
                            PkRecord record = anchorQueryInfo.pkRecord;
                            if (record != null && (record.status == LiveStatus.PK_LIVING || record.status == LiveStatus.PK_PUNISHMENT)) {
                                getAudiencePKControl().showPkMaskUI(canRender,anchorQueryInfo,liveInfo);
                            }
                            // 多人连麦观众列表
                            if (anchorQueryInfo.seatList!=null&&!anchorQueryInfo.seatList.isEmpty()){
                                boolean isInSeat=false;
                                for (SeatMemberInfo memberInfo : anchorQueryInfo.seatList) {

                                    // 自己通过代码showCurrentUI中的addSelfToLinkSeatsRv添加
                                    if (!AccountUtil.isCurrentUser(memberInfo.accountId)){
                                        linkSeatsRv.appendItem(memberInfo);
                                    }else {
                                        isInSeat=true;
                                    }
                                }
                                if (isInSeat){
                                    if (isFirstShowNormalUI){
                                         showCurrentUI(false,true);
                                    }else {
                                        // 网络重连恢复到连麦模式
                                        if (refreshLinkedSeatsUI){
                                            linkSeatsRv.getAdapter().notifyDataSetChanged();
                                        }
                                        showCurrentUI(true,false);
                                    }

                                }else {
                                    showCurrentUI(false,true);
                                    //接口请求的直播间信息中的连麦观众中不包含自己的时候才需要展示CDN连麦样式
                                    videoView.setLinkingSeats(true);
                                }
                            }else {
                                showCurrentUI(false,true);
                            }
                            changeErrorState(false, -1);
                            isFirstShowNormalUI=false;
                        } else if (response.code == LiveServerApi.ERROR_CODE_ROOM_NOT_EXIST || response.code == LiveServerApi.ERROR_CODE_USER_NOT_IN_ROOM) {
                            changeErrorState(true, AudienceErrorStateView.TYPE_FINISHED);
                        } else {
                            changeErrorState(true, AudienceErrorStateView.TYPE_ERROR);
                            ALog.e(TAG, "获取房间信息失败，返回消息为 " + response);
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        ALog.e(TAG, "获取房间信息失败");
                        changeErrorState(true, AudienceErrorStateView.TYPE_ERROR);
                    }
                });
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        int x = (int) ev.getRawX();
        int y = (int) ev.getRawY();
        // 键盘区域外点击收起键盘
        if (!ViewUtils.isInView(infoBinding.etRoomMsgInput, x, y)) {
            InputUtils.hideSoftInput(infoBinding.etRoomMsgInput);
        }
        return super.dispatchTouchEvent(ev);
    }
    private void joinRtcAndShowRtcUI(SeatMemberInfo member) {
        if (member==null){
            ToastUtils.showShort("joinRtcAndShowRtcUI error,member==null");
            return;
        }
        //需要把主播画面的CDN流改为RTC流，右边需要添加小的RTC流
        waitAnchorAcceptFloatLayer.setVisibility(GONE);
        errorStateView.setVisibility(GONE);
        initForLiveType(true);
        UserModel currentUser = userCenterService.getCurrentUser();
        if (currentUser != null) {
            String avRoomUid = currentUser.avRoomUid;
            if (!TextUtils.isEmpty(avRoomUid)) {
                try {
                    linkedSeatsAudienceActionManager.joinRtcChannel(member.avRoomCheckSum,member.avRoomCName,Long.parseLong(avRoomUid),member.avRoomCid);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            } else {
                ALog.d(TAG, "joinRtcAndshowRtcUI avRoomUid为空");
            }
        }

    }


    /**
     * 把自己添加到连麦观众列表的视图中
     */
    private void addSelfToLinkSeatsRv(UserModel currentUser) {
        int selfIndex = 0;
        SeatMemberInfo member = new SeatMemberInfo();
        member.accountId=currentUser.accountId;
        member.nickName = currentUser.nickname;
        member.avatar = currentUser.avatar;
        member.audio = AudioActionType.OPEN;
        member.video = VideoActionType.OPEN;
        linkSeatsRv.appendItem(selfIndex, member);
    }

    private AudiencePKControl getAudiencePKControl(){
        if (audiencePKControl==null){
            audiencePKControl=new AudiencePKControl();
            audiencePKControl.init(activity,videoView,infoBinding.getRoot());
        }
        return audiencePKControl;
    }

    private AudienceDialogControl getAudienceDialogControl(){
        if (audienceDialogControl==null){
            audienceDialogControl=new AudienceDialogControl();
        }
        return audienceDialogControl;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        NetworkUtils.registerNetworkStatusChangedListener(onNetworkStatusChangedListener);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        NetworkUtils.unregisterNetworkStatusChangedListener(onNetworkStatusChangedListener);
    }

    public static boolean isNetworkConnected(Context context) {
        if (context != null) {
            ConnectivityManager mConnectivityManager = (ConnectivityManager) context
                    .getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo mNetworkInfo = mConnectivityManager.getActiveNetworkInfo();
            if (mNetworkInfo != null) {
                return mNetworkInfo.isAvailable();
            }
        }
        return false;
    }

}
