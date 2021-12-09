/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo

import android.os.Bundle
import androidx.viewpager.widget.ViewPager
import com.google.android.material.tabs.TabLayout
import com.netease.biz_live.yunxin.live.floatplay.FloatPlayManager
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.login.sdk.AuthorManager
import com.netease.yunxin.login.sdk.model.EventType
import com.netease.yunxin.login.sdk.model.LoginEvent
import com.netease.yunxin.login.sdk.model.LoginObserver
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import com.netease.yunxin.nertc.demo.pager.MainPagerAdapter

class MainActivity : BaseActivity() {
    companion object{
        private const val TAG="MainActivity"
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        NetworkClient.getInstance().configAccessToken(AuthorManager.getUserInfo()?.accessToken)
        val mainPager = findViewById<ViewPager>(R.id.vp_fragment)
        mainPager.adapter = MainPagerAdapter(supportFragmentManager)
        mainPager.offscreenPageLimit = 2
        val tabLayout = findViewById<TabLayout>(R.id.tl_tab)
        tabLayout.setupWithViewPager(mainPager)
        tabLayout.removeAllTabs()
        tabLayout.tabGravity = TabLayout.GRAVITY_CENTER
        tabLayout.setSelectedTabIndicator(null)
        tabLayout.addTab(tabLayout.newTab().setCustomView(R.layout.view_item_home_tab_app), 0, true)
        tabLayout.addTab(
            tabLayout.newTab().setCustomView(R.layout.view_item_home_tab_user),
            1,
            false
        )
        mainPager.addOnPageChangeListener(object :
            TabLayout.TabLayoutOnPageChangeListener(tabLayout) {
            override fun onPageSelected(position: Int) {
                val item = tabLayout.getTabAt(position)
                item?.select()
                super.onPageSelected(position)
            }
        })

        AuthorManager.registerLoginObserver(object : LoginObserver<LoginEvent> {
            override fun onEvent(t: LoginEvent) {
                if (t.eventType == EventType.TYPE_LOGOUT) {
                    ALog.d(TAG,"LOGOUT")
                    if (FloatPlayManager.isStartFloatWindow) {
                        FloatPlayManager.closeFloatPlay()
                    }
                }
            }

        })
    }

    override fun onDestroy() {
        super.onDestroy()
        //        CallService.stop(this);
        ALog.flush(true)
        ALog.release()
    }

    override fun provideStatusBarConfig(): StatusBarConfig? {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .build()
    }
}