package com.netease.biz_live.yunxin.live.dialog;

import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.viewpager.widget.ViewPager;

import com.blankj.utilcode.util.ColorUtils;
import com.blankj.utilcode.util.ScreenUtils;
import com.blankj.utilcode.util.ViewUtils;
import com.google.android.material.tabs.TabLayout;
import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.dialog.adapter.AudiencePageAdapter;
import com.netease.yunxin.nertc.demo.utils.SpUtils;


/**
 * 观众连麦dialog
 */
public class AudienceConnectDialog extends BaseBottomDialog{

    private TextView tvInviteCount;

    private TextView tvApplyCount;

    private TextView tvConnectManage;

    private String roomId;

    public static final String ROOM_ID = "roomId";

    public AudienceConnectDialog(){

    }

    @Override
    protected int getResourceLayout() {
        return R.layout.audience_connect_dialog_layout;
    }

    @Override
    protected void initView(View rootView) {
        super.initView(rootView);

        if(getArguments() != null){
            Bundle bundle = getArguments();
            roomId = bundle.getString(ROOM_ID);
        }

        ViewPager audiencePages = rootView.findViewById(R.id.vp_audience);
        audiencePages.setAdapter(new AudiencePageAdapter(getChildFragmentManager(),roomId));
        audiencePages.setOffscreenPageLimit(3);

        TabLayout tabLayout = rootView.findViewById(R.id.tab_audience_type);
        tabLayout.setupWithViewPager(audiencePages);
        tabLayout.removeAllTabs();
        tabLayout.setTabGravity(TabLayout.GRAVITY_FILL);
        TabLayout.Tab tab1 = tabLayout.newTab().setCustomView(R.layout.view_item_audience_tab);
        tvInviteCount = tab1.getCustomView().findViewById(R.id.tv_tab_name);
        tvInviteCount.setText("邀请上麦");
        tabLayout.addTab(tab1, 0, false);
        TabLayout.Tab tab2 = tabLayout.newTab().setCustomView(R.layout.view_item_audience_tab);
        tvApplyCount = tab2.getCustomView().findViewById(R.id.tv_tab_name);
        tvApplyCount.setText("连麦申请");
        tabLayout.addTab(tab2, 1, true);
        TabLayout.Tab tab3 = tabLayout.newTab().setCustomView(R.layout.view_item_audience_tab);
        tvConnectManage = tab3.getCustomView().findViewById(R.id.tv_tab_name);
        tvConnectManage.setText("连麦管理");
        tabLayout.addTab(tab3, 2, false);
        audiencePages.setCurrentItem(1);
    }

    @Override
    protected void initParams() {
        Window window = getDialog().getWindow();
        if (window != null) {
            window.setBackgroundDrawableResource(R.drawable.white_corner_bottom_dialog_bg);

            WindowManager.LayoutParams params = window.getAttributes();
            params.gravity = Gravity.BOTTOM;
            // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
            params.width = ViewGroup.LayoutParams.MATCH_PARENT;
            params.height = ScreenUtils.getScreenHeight() / 3;
            window.setAttributes(params);

        }
        setCancelable(true);//设置点击外部是否消失
    }


}
