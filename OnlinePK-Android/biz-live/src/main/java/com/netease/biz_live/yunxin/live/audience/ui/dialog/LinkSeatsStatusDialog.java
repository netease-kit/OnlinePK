/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.audience.ui.dialog;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter;
import com.netease.biz_live.yunxin.live.audience.ui.view.DurationStatisticTimer;
import com.netease.biz_live.yunxin.live.audience.utils.LinkedSeatsAudienceActionManager;
import com.netease.biz_live.yunxin.live.constant.AudioActionType;
import com.netease.biz_live.yunxin.live.constant.VideoActionType;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.ArrayList;
import java.util.List;

/**
 * @author sunkeding
 * 连麦状态弹窗
 */
public class LinkSeatsStatusDialog extends BottomBaseDialog {
    private static final int GRID_SPAN_COUNT = 5;
    private LinkedSeatsAudienceActionManager linkedSeatsAudienceActionManager;
    private DurationStatisticTimer durationStatisticTimer;
    private InnerAdapter adapter;
    public static final int CAMERA_POSITION=3;
    public static final int MICROPHONE_POSITION=4;
    public LinkSeatsStatusDialog(@NonNull Activity activity, LinkedSeatsAudienceActionManager linkedSeatsAudienceActionManager) {
        super(activity);
        this.linkedSeatsAudienceActionManager = linkedSeatsAudienceActionManager;
    }

    @Override
    protected void renderTopView(FrameLayout parent) {
        TextView titleView = new TextView(getContext());
        titleView.setText(R.string.biz_live_link_seats_status);
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
        titleView.setGravity(Gravity.CENTER);
        titleView.setTextColor(Color.parseColor("#ff333333"));
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        parent.addView(titleView, layoutParams);
    }

    @Override
    protected void renderBottomView(FrameLayout parent) {
        View bottomView = LayoutInflater.from(getContext()).inflate(R.layout.view_dialog_bottom_microphone_status, parent);
        RecyclerView recyclerView = bottomView.findViewById(R.id.rv);
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), GRID_SPAN_COUNT));
        adapter = new InnerAdapter(getContext(), getButtonData());
        recyclerView.setAdapter(adapter);
        adapter.setOptionClickListener(new OptionClickListener() {
            @Override
            public void clickBeauty() {
                linkedSeatsAudienceActionManager.showBeautySettingDialog();
            }

            @Override
            public void clickFilter() {
                linkedSeatsAudienceActionManager.showFilterSettingDialog();
            }

            @Override
            public void clickHangup() {
                linkedSeatsAudienceActionManager.leaveSeat(linkedSeatsAudienceActionManager.liveInfo.liveCid, new LiveRoomCallback<Void>() {
                    @Override
                    protected void onSuccess() {
                        super.onSuccess();
                        if (isShowing()) {
                            dismiss();
                        }
                    }

                    @Override
                    public void onError(int code, String msg) {
                        ToastUtils.showShort(msg);
                        if (isShowing()) {
                            dismiss();
                        }
                    }
                });

            }

            @Override
            public void clickCamere(ImageView iv) {
                linkedSeatsAudienceActionManager.switchCamera(iv);
            }

            @Override
            public void clickMicrophone(ImageView iv) {
                linkedSeatsAudienceActionManager.switchMicrophone(iv);
            }
        });


        durationStatisticTimer = bottomView.findViewById(R.id.tv_duration);
        ImageView imageView = bottomView.findViewById(R.id.iv);
        durationStatisticTimer.start();
        ImageLoader.with(getContext().getApplicationContext())
                .circleLoad(ModuleServiceMgr.getInstance().getService(UserCenterService.class).getCurrentUser().avatar, imageView);
    }

    private List<OptionButtonInfo> getButtonData() {
        ArrayList<OptionButtonInfo> optionButtonInfos = new ArrayList<>();
        optionButtonInfos.add(new OptionButtonInfo(OptionButtonInfo.Type.ITEM_BEAUTY, R.drawable.biz_live_beauty, activity.getString(R.string.biz_live_beauty_text)));
        optionButtonInfos.add(new OptionButtonInfo(OptionButtonInfo.Type.ITEM_FILTER, R.drawable.biz_live_filter, activity.getString(R.string.biz_live_filter_text)));
        optionButtonInfos.add(new OptionButtonInfo(OptionButtonInfo.Type.ITEM_HANGUP, R.drawable.biz_live_hangup, activity.getString(R.string.biz_live_hangup_text)));
        optionButtonInfos.add(new OptionButtonInfo(OptionButtonInfo.Type.ITEM_CAMERA, LinkedSeatsAudienceActionManager.enableLocalVideo ? R.drawable.biz_live_camera : R.drawable.biz_live_camera_close, activity.getString(R.string.biz_live_camera_text)));
        optionButtonInfos.add(new OptionButtonInfo(OptionButtonInfo.Type.ITEM_MICROPHOHE, LinkedSeatsAudienceActionManager.enableLocalAudio ? R.drawable.biz_live_microphone : R.drawable.biz_live_microphone_close, activity.getString(R.string.biz_live_microphone_text)));
        return optionButtonInfos;
    }

    @Override
    public void dismiss() {
        durationStatisticTimer.stop();
        super.dismiss();
    }

    public void refreshLinkSeatDialog(int position, int openState){
         if (position==CAMERA_POSITION){
             adapter.getDataSource().set(position,new OptionButtonInfo(OptionButtonInfo.Type.ITEM_CAMERA,openState== VideoActionType.OPEN ?R.drawable.biz_live_camera : R.drawable.biz_live_camera_close,activity.getString(R.string.biz_live_camera_text)));
         }else if (position==MICROPHONE_POSITION){
             adapter.getDataSource().set(position,new OptionButtonInfo(OptionButtonInfo.Type.ITEM_MICROPHOHE,openState== AudioActionType.OPEN ?R.drawable.biz_live_microphone : R.drawable.biz_live_microphone_close,activity.getString(R.string.biz_live_microphone_text)));
         }
         adapter.notifyItemChanged(position);
    }

    /**
     * 操作按钮列表 adapter
     */
    private static class InnerAdapter extends LiveBaseAdapter<OptionButtonInfo> {
        private OptionClickListener optionClickListener;

        public InnerAdapter(Context context, List<OptionButtonInfo> dataSource) {
            super(context, dataSource);
        }

        public void setOptionClickListener(OptionClickListener optionClickListener) {
            this.optionClickListener = optionClickListener;
        }
        public void refresh(List<OptionButtonInfo> dataSource){
            updateDataSource(dataSource);
        }
        @Override
        protected int getLayoutId(int viewType) {
            return R.layout.view_item_dialog_option_button;
        }

        @Override
        protected LiveViewHolder onCreateViewHolder(View itemView) {
            return new LiveViewHolder(itemView);
        }

        @Override
        protected void onBindViewHolder(LiveViewHolder holder, OptionButtonInfo itemData) {
            ImageView iv = holder.getView(R.id.iv);
            TextView tvName = holder.getView(R.id.tv);
            iv.setImageResource(itemData.resId);
            tvName.setText(itemData.name);
            holder.itemView.setOnClickListener(v -> {
                if (optionClickListener != null) {
                    switch (itemData.id) {
                        case 0:
                            optionClickListener.clickBeauty();
                            break;
                        case 1:
                            optionClickListener.clickFilter();
                            break;
                        case 2:
                            optionClickListener.clickHangup();
                            break;
                        case 3:
                            optionClickListener.clickCamere(iv);
                            break;
                        case 4:
                            optionClickListener.clickMicrophone(iv);
                            break;
                        default:
                            break;
                    }

                }
            });
        }

    }

    private class OptionButtonInfo {
        public int id;
        public int resId;
        public String name;

        public OptionButtonInfo(int id, int resId, String name) {
            this.id = id;
            this.resId = resId;
            this.name = name;
        }

        public class Type {
            public static final int ITEM_BEAUTY = 0;
            public static final int ITEM_FILTER = 1;
            public static final int ITEM_HANGUP = 2;
            public static final int ITEM_CAMERA = 3;
            public static final int ITEM_MICROPHOHE = 4;
        }
    }

    public interface OptionClickListener {
        void clickBeauty();

        void clickFilter();

        void clickHangup();

        void clickCamere(ImageView iv);

        void clickMicrophone(ImageView iv);
    }
}
