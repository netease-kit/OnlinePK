/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.ui.widget;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.netease.biz_live.R;

public class AnchorActionView extends LinearLayout {

    private TextView tvComment;

    private TextView tvBlack;

    private TextView tvColor;

    private String audienceNick;

    private int count;

    public AnchorActionView(Context context) {
        super(context);
        initView();
    }

    public AnchorActionView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public AnchorActionView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    private void initView(){
        LayoutInflater.from(getContext()).inflate(R.layout.view_anchor_aciton,this);
        tvComment = findViewById(R.id.tv_comment);
        tvBlack = findViewById(R.id.tv_black);
        tvColor = findViewById(R.id.tv_color);
    }

    public AnchorActionView setBlackButton(boolean show, String text, OnClickListener clickListener){
        tvBlack.setVisibility(show?VISIBLE:GONE);
        tvBlack.setText(TextUtils.isEmpty(text)?"":text);
        tvBlack.setOnClickListener(v -> {
            hide();
            if(clickListener != null) {
                clickListener.onClick(v);
            }
        });
        return this;
    }

    public AnchorActionView setText(String text){
        tvComment.setText(text);
        return this;
    }


    public AnchorActionView setColorButton(String text, OnClickListener clickListener){
        tvColor.setText(TextUtils.isEmpty(text)?"":text);
        tvColor.setOnClickListener(v -> {
            hide();
            if(clickListener != null) {
                clickListener.onClick(v);
            }
        });
        return this;
    }


    public boolean isShowing(){
        return this.getVisibility() == VISIBLE;
    }

    public void show(){
        setVisibility(VISIBLE);
    }

    public void hide(){
        setVisibility(GONE);
        tvColor.setText("");
        tvComment.setText("");
        tvBlack.setText("");
        tvBlack.setVisibility(GONE);
        audienceNick = "";
        count = 0;
    }
}
