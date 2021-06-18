/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.dialog;

import android.app.Activity;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.blankj.utilcode.util.SPUtils;
import com.netease.biz_live.R;
import com.netease.yunxin.nertc.demo.utils.SpUtils;

/**
 * @author sunkeding
 * 无标题的提示弹窗
 */
public class TipsDialog extends ChoiceDialog {

    public TipsDialog(@NonNull Activity activity) {
        super(activity);
        setCancelable(false);
    }

    @Override
    protected void renderRootView(View rootView) {
        super.renderRootView(rootView);
        rootView.findViewById(R.id.line_divide).setVisibility(View.GONE);
        rootView.findViewById(R.id.tv_dialog_negative).setVisibility(View.GONE);

        TextView tvTitle = rootView.findViewById(R.id.tv_dialog_title);
        tvTitle.setVisibility(View.GONE);

        TextView tvContent = rootView.findViewById(R.id.tv_dialog_content);
        RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) tvContent.getLayoutParams();
        params.topMargin= SpUtils.dp2pix(getContext(),24);
        tvContent.setLayoutParams(params);
        tvContent.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 15f);

        View line_bottom = rootView.findViewById(R.id.line_bottom);
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) line_bottom.getLayoutParams();
        layoutParams.topMargin= SpUtils.dp2pix(getContext(),24);
        line_bottom.setLayoutParams(layoutParams);


    }
}