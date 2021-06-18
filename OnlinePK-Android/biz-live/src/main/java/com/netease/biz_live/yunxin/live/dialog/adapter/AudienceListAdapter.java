/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.dialog.adapter;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.dialog.ChoiceDialog;
import com.netease.biz_live.yunxin.live.dialog.fragment.AudienceListFragment;
import com.netease.biz_live.yunxin.live.liveroom.AnchorSeatManager;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.NERTCLiveRoom;
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;
import com.netease.biz_live.yunxin.live.utils.ClickUtils;
import com.netease.yunxin.android.lib.picture.ImageLoader;

import java.util.ArrayList;
import java.util.List;

/**
 * 观众列表
 */
public class AudienceListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private ArrayList<SeatMemberInfo> memberInfos;

    private int type;

    private Activity context;

    private AnchorSeatManager seatManager;

    public AudienceListAdapter(Activity context, int type) {
        memberInfos = new ArrayList<>();
        this.type = type;
        this.context = context;
        seatManager = NERTCLiveRoom.sharedInstance(true).getService(AnchorSeatManager.class);
    }

    public void setData(List<SeatMemberInfo> members){
        if(members == null){
            return;
        }
        memberInfos.clear();
        memberInfos.addAll(members);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType){
            case AudienceListFragment.TYPE_APPLY:
                View apply = LayoutInflater.from(parent.getContext()).inflate(R.layout.view_item_audience_apply, parent, false);
                return new ApplyAudienceViewHolder(apply);
            case AudienceListFragment.TYPE_MANAGER:
                View seat = LayoutInflater.from(parent.getContext()).inflate(R.layout.view_item_audience_seats, parent, false);
                return new SeatAudienceViewHolder(seat);
            default:
                View common = LayoutInflater.from(parent.getContext()).inflate(R.layout.view_item_audience_common, parent, false);
                return new AudienceCommonViewHolder(common);
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (context == null) {
            return;
        }
        if (holder instanceof AudienceViewHolder) {
            SeatMemberInfo member = memberInfos.get(position);
            ((AudienceViewHolder) holder).mTvNumber.setText(String.valueOf(position + 1));
            ((AudienceViewHolder) holder).mTvNick.setText(member.nickName);
            ImageLoader.with(context).circleLoad(member.avatar, ((AudienceViewHolder) holder).mIvAvatar);
            if (holder instanceof AudienceCommonViewHolder) {
                ((AudienceCommonViewHolder) holder).mTvInvite.setOnClickListener(v -> {
                    if (ClickUtils.isFastClick()) {
                        return;
                    }
                    if (seatManager != null) {
                        seatManager.pickSeat(member.accountId, new LiveRoomCallback<Void>() {
                            @Override
                            protected void onSuccess() {
                                super.onSuccess();
                                removeMember(member);
                                ToastUtils.showShort(R.string.anchor_invite_success);
                            }

                            @Override
                            public void onError(int code, String msg) {
                                ToastUtils.showShort(msg);
                            }
                        });
                    }
                });
            }else if(holder instanceof ApplyAudienceViewHolder){
                ((ApplyAudienceViewHolder) holder).mTvAccept.setOnClickListener(v -> {
                    if (ClickUtils.isFastClick()) {
                        return;
                    }
                    if (seatManager != null) {
                        seatManager.acceptSeatApply(member.accountId, new LiveRoomCallback<Void>() {
                            @Override
                            protected void onSuccess() {
                                super.onSuccess();
                                removeMember(member);
                                ToastUtils.showShort(R.string.have_accept);
                            }

                            @Override
                            public void onError(int code, String msg) {
                                ToastUtils.showShort(msg);
                            }
                        });
                    }
                });
                ((ApplyAudienceViewHolder) holder).mTvReject.setOnClickListener(v -> {
                    if (ClickUtils.isFastClick()) {
                        return;
                    }
                    if (seatManager != null) {
                        seatManager.rejectSeatApply(member.accountId, new LiveRoomCallback<Void>() {
                            @Override
                            protected void onSuccess() {
                                super.onSuccess();
                                removeMember(member);
                                ToastUtils.showShort(R.string.have_reject);
                            }

                            @Override
                            public void onError(int code, String msg) {
                                ToastUtils.showShort(msg);
                            }
                        });
                    }
                });
            }else if(holder instanceof  SeatAudienceViewHolder){
                ((SeatAudienceViewHolder) holder).mIvAudio.setSelected(member.audio == 0);
                ((SeatAudienceViewHolder) holder).mIvVideo.setSelected(member.video == 0);
                ((SeatAudienceViewHolder) holder).mIvAudio.setOnClickListener(v -> {
                    if (ClickUtils.isFastClick()) {
                        return;
                    }
                    if (seatManager != null) {
                        seatManager.setSeatMuteState(member.accountId, v.isSelected() ? 1 : 0, member.video, new LiveRoomCallback<Void>() {
                            @Override
                            protected void onSuccess() {
                                super.onSuccess();
                                v.setSelected(!v.isSelected());
                                member.audio = v.isSelected() ? 0 : 1;
                            }

                            @Override
                            public void onError(int code, String msg) {
                                ToastUtils.showShort(msg);
                            }
                        });
                    }
                });
                ((SeatAudienceViewHolder) holder).mIvVideo.setOnClickListener(v -> {
                    if (ClickUtils.isFastClick()) {
                        return;
                    }
                    if (seatManager != null) {
                        seatManager.setSeatMuteState(member.accountId, member.audio, v.isSelected() ? 1 : 0, new LiveRoomCallback<Void>() {
                            @Override
                            protected void onSuccess() {
                                super.onSuccess();
                                v.setSelected(!v.isSelected());
                                member.video = v.isSelected() ? 0 : 1;
                            }

                            @Override
                            public void onError(int code, String msg) {
                                ToastUtils.showShort(msg);
                            }
                        });
                    }
                });
                ((SeatAudienceViewHolder) holder).mTvHangup.setOnClickListener(v -> {
                    if (ClickUtils.isFastClick()) {
                        return;
                    }
                    showKickDialog(member);
                });
            }
        }
    }

    private void removeMember(SeatMemberInfo member) {
        int index = memberInfos.indexOf(member);
        if (index >= 0) {
            memberInfos.remove(index);
            notifyItemRemoved(index);
        }
    }

    /**
     * 踢下麦二次确认
     *
     * @param member
     */
    private void showKickDialog(SeatMemberInfo member) {
        if (context == null) {
            return;
        }
        ChoiceDialog dialog = new ChoiceDialog(context);
        dialog.setContent(String.format("是否挂断与%s的连麦？", member.nickName))
                .setNegative("取消", v -> {
                })
                .setPositive("挂断", v -> {
                    if (seatManager != null) {
                        seatManager.kickSeat(member.accountId, new LiveRoomCallback<Void>() {

                            @Override
                            protected void onSuccess() {
                                super.onSuccess();
                                removeMember(member);
                                ToastUtils.showShort(R.string.have_leave_seat);
                            }

                            @Override
                            public void onError(int code, String msg) {
                                ToastUtils.showShort(msg);
                            }
                        });
                    }
                }).show();
    }

    @Override
    public int getItemViewType(int position) {
        return type;
    }

    @Override
    public int getItemCount() {
        return memberInfos.size();
    }

    private static class AudienceViewHolder extends RecyclerView.ViewHolder{

        public TextView mTvNumber;

        public ImageView mIvAvatar;

        public TextView mTvNick;

        public AudienceViewHolder(@NonNull View itemView) {
            super(itemView);
            mTvNumber = itemView.findViewById(R.id.tv_audience_no);
            mIvAvatar = itemView.findViewById(R.id.iv_audience_avatar);
            mTvNick = itemView.findViewById(R.id.tv_audience_nickname);
        }
    }

    private static class AudienceCommonViewHolder extends AudienceViewHolder{

        public TextView mTvInvite;

        public AudienceCommonViewHolder(@NonNull View itemView) {
            super(itemView);
            mTvInvite = itemView.findViewById(R.id.tv_invite);
        }
    }

    private static class ApplyAudienceViewHolder extends AudienceViewHolder{

        public TextView mTvReject;

        public TextView mTvAccept;

        public ApplyAudienceViewHolder(@NonNull View itemView) {
            super(itemView);
            mTvAccept = itemView.findViewById(R.id.tv_accept);

            mTvReject = itemView.findViewById(R.id.tv_reject);
        }
    }

    private static class SeatAudienceViewHolder extends AudienceViewHolder{

        public ImageView mIvVideo;

        public ImageView mIvAudio;

        public TextView mTvHangup;

        public SeatAudienceViewHolder(@NonNull View itemView) {
            super(itemView);
            mIvVideo = itemView.findViewById(R.id.iv_video);

            mIvAudio = itemView.findViewById(R.id.iv_audio);

            mTvHangup = itemView.findViewById(R.id.tv_hangup);
        }
    }
}
