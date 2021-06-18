/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.ui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.network.LiveInteraction;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.nertc.demo.utils.SpUtils;

import io.reactivex.observers.ResourceSingleObserver;

public class AnchorPreview extends FrameLayout {
    //摄像头翻转按钮
    public ImageView ivSwitchCamera;
    //美颜
    public LinearLayout llyBeauty;
    //设置
    public LinearLayout llySetting;
    //滤镜
    public LinearLayout llyFilter;

    private EditText edtTopic;

    public Button btnLiveCreate;//开始直播
    //关闭
    public ImageView ivClose;
    //封面
    private ImageView ivCover;
    //随机topic
    public ImageView ivRandom;

    public ImageView ivRefreshPic;

    private String liveCoverPic;


    public AnchorPreview(@NonNull Context context) {
        super(context);
        initView();
    }

    public AnchorPreview(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public AnchorPreview(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    private void initView(){
        LayoutInflater.from(getContext()).inflate(R.layout.anchor_preview_layout,this);
        ivSwitchCamera = findViewById(R.id.iv_camera_switch);
        llyBeauty = findViewById(R.id.lly_beauty);
        llySetting = findViewById(R.id.lly_setting);
        llyFilter = findViewById(R.id.lly_filter);
        edtTopic = findViewById(R.id.edt_live_title);
        btnLiveCreate = findViewById(R.id.btn_start_live);
        ivClose = findViewById(R.id.iv_back);
        ivCover = findViewById(R.id.iv_cover);
        ivRandom = findViewById(R.id.iv_dice);
        ivRefreshPic = findViewById(R.id.iv_refresh_pic);
        getRandomCover();
        getRandomTopic();
        ivRandom.setOnClickListener(v -> getRandomTopic());
        ivRefreshPic.setOnClickListener(v -> getRandomCover());
    }

    /**
     * 获取随机封面
     */
    private void getRandomCover() {
        LiveInteraction.getCover().subscribe(new ResourceSingleObserver<BaseResponse<String>>() {
            @Override
            public void onSuccess(BaseResponse<String> stringBaseResponse) {
                if (stringBaseResponse.code == 200) {
                    liveCoverPic = stringBaseResponse.data;
                    ImageLoader.with(getContext()).roundedCorner(stringBaseResponse.data, SpUtils.dp2pix(getContext(), 4), ivCover);
                }
            }

            @Override
            public void onError(Throwable e) {

            }
        });
    }

    private void getRandomTopic() {
        LiveInteraction.getTopic().subscribe(new ResourceSingleObserver<BaseResponse<String>>() {
            @Override
            public void onSuccess(BaseResponse<String> stringBaseResponse) {
                if (stringBaseResponse.code == 200) {
                    edtTopic.setText(stringBaseResponse.data);
                }
            }

            @Override
            public void onError(Throwable e) {

            }
        });
    }

    public String getTopic(){
        return edtTopic.getText().toString().trim();
    }

    public String getLiveCoverPic() {
        return liveCoverPic;
    }

    public void setCreateEnable(boolean enable){
        btnLiveCreate.setEnabled(enable);
    }
}
