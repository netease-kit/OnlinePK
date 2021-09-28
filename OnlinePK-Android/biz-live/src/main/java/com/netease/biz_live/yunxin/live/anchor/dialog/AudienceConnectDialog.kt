/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.dialog

import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.viewpager.widget.ViewPager
import com.blankj.utilcode.util.ScreenUtils
import com.google.android.material.tabs.TabLayout
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.anchor.dialog.adapter.AudiencePageAdapter
import com.netease.biz_live.yunxin.live.dialog.BaseBottomDialog

/**
 * 观众连麦dialog
 */
class AudienceConnectDialog : BaseBottomDialog() {
    private var tvInviteCount: TextView? = null
    private var tvApplyCount: TextView? = null
    private var tvConnectManage: TextView? = null
    private var roomId: String? = null
    override fun getResourceLayout(): Int {
        return R.layout.audience_connect_dialog_layout
    }

    override fun initView(rootView: View) {
        super.initView(rootView)
        arguments?.let {
            val bundle = it
            roomId = bundle.getString(ROOM_ID)
        }
        val audiencePages: ViewPager = rootView.findViewById(R.id.vp_audience)
        audiencePages.adapter = roomId?.let { AudiencePageAdapter(childFragmentManager, it) }
        audiencePages.offscreenPageLimit = 3
        val tabLayout: TabLayout = rootView.findViewById(R.id.tab_audience_type)
        tabLayout.setupWithViewPager(audiencePages)
        tabLayout.removeAllTabs()
        tabLayout.tabGravity = TabLayout.GRAVITY_FILL
        val tab1 = tabLayout.newTab().setCustomView(R.layout.view_item_audience_tab)
        tvInviteCount = tab1.customView?.findViewById(R.id.tv_tab_name)
        tvInviteCount?.text = getString(R.string.biz_live_invite_join_seats)
        tabLayout.addTab(tab1, 0, false)
        val tab2 = tabLayout.newTab().setCustomView(R.layout.view_item_audience_tab)
        tvApplyCount = tab2.customView?.findViewById(R.id.tv_tab_name)
        tvApplyCount?.setText(R.string.biz_live_apply_seat)
        tabLayout.addTab(tab2, 1, true)
        val tab3 = tabLayout.newTab().setCustomView(R.layout.view_item_audience_tab)
        tvConnectManage = tab3.customView?.findViewById(R.id.tv_tab_name)
        tvConnectManage?.setText(R.string.biz_live_apply_seat_manager)
        tabLayout.addTab(tab3, 2, false)
        audiencePages.currentItem = 1
    }

    override fun initParams() {
        val window = dialog?.window
        window?.let {
            it.setBackgroundDrawableResource(R.drawable.white_corner_bottom_dialog_bg)
            val params = it.attributes
            params.gravity = Gravity.BOTTOM
            // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
            params.width = ViewGroup.LayoutParams.MATCH_PARENT
            params.height = ScreenUtils.getScreenHeight() / 3
            it.attributes = params
        }
        isCancelable = true //设置点击外部是否消失
    }

    companion object {
        const val ROOM_ID: String = "roomId"
    }
}