/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.ui.widget;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.utils.AccountUtil;
import com.netease.biz_live.yunxin.live.liveroom.NERTCLiveRoom;
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;
import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.yunxin.android.lib.picture.ImageLoader;

/**
 * @author sunkeding
 * 单个连麦观众麦位视图
 */
public class SingleAudienceSeatsView extends FrameLayout {
    private static final int ENABLE = 1;
    private SeatMemberInfo member;
    private View flMask;
    private TextView tvNickName;
    private ImageView ivMicrophone;
    private ImageView ivHeader;
    private ImageView ivClose;
    private NERtcVideoView rtcView;
    private NERTCLiveRoom liveRoom;
    /**
     * 是否是主播
     */
    private boolean isAnchor;

    public SingleAudienceSeatsView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public SingleAudienceSeatsView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public SingleAudienceSeatsView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        LayoutInflater.from(context).inflate(R.layout.biz_live_audience_seats_layout, this);
        flMask = findViewById(R.id.fl_mask);
        tvNickName = findViewById(R.id.tv_nickname);
        ivMicrophone = findViewById(R.id.iv_microphone);
        ivHeader = findViewById(R.id.iv_header);
        rtcView = findViewById(R.id.rtc_view);
        ivClose = findViewById(R.id.iv_close);
        ivClose.setOnClickListener(v -> {
            if (closeSeatCallback != null && member != null) {
                closeSeatCallback.closeSeat(member);
            }
        });

    }

    public void initLiveRoom(NERtcOption option, boolean isAnchor) {
        liveRoom = NERTCLiveRoom.sharedInstance(isAnchor);
        this.isAnchor=isAnchor;
    }

    public void setData(SeatMemberInfo member) {
        if (liveRoom == null||member==null) {
            return;
        }
        this.member = member;
        tvNickName.setText(member.nickName);
        ivMicrophone.setImageResource(member.audio == ENABLE ? R.drawable.biz_live_microphone_open_status : R.drawable.biz_live_microphone_close_status);
        if (member.video == ENABLE) {
            ivHeader.setVisibility(GONE);
            flMask.setBackgroundColor(Color.TRANSPARENT);
            try {
                if (!isAnchor&& AccountUtil.isCurrentUser(member.accountId)) {
                    liveRoom.setupLocalView(rtcView);
                } else {
                    liveRoom.setupRemoteView(rtcView, member.avRoomUid, true);
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        } else {
            ivHeader.setVisibility(VISIBLE);
            flMask.setBackgroundColor(Color.parseColor("#222222"));
            ImageLoader.with(getContext().getApplicationContext())
                    .circleLoad(member.avatar, ivHeader);
        }
        // 右上角x逻辑
        if (isAnchor) {
            ivClose.setVisibility(VISIBLE);
        } else {
            if (AccountUtil.isCurrentUser(member.accountId)) {
                ivClose.setVisibility(VISIBLE);
            } else {
                ivClose.setVisibility(GONE);
            }
        }
    }

    public void setCloseSeatCallback(CloseSeatCallback closeSeatCallback) {
        this.closeSeatCallback = closeSeatCallback;
    }

    private CloseSeatCallback closeSeatCallback;

    public interface CloseSeatCallback {
        /**
         * 点击右上角X的回调，主播端是把观众踢下麦，观众端是自己下麦
         */
        void closeSeat(SeatMemberInfo member);
    }
}
