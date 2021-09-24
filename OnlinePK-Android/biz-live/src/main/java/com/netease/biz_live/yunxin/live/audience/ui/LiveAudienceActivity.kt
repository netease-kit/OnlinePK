/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.adapter.LiveAnchorListAdapter
import com.netease.biz_live.yunxin.live.audience.ui.view.BaseAudienceContentView
import com.netease.biz_live.yunxin.live.audience.ui.view.ExtraTransparentView
import com.netease.biz_live.yunxin.live.audience.ui.view.PagerVerticalLayoutManager
import com.netease.biz_live.yunxin.live.audience.ui.view.PagerVerticalLayoutManager.OnPageChangedListener
import com.netease.biz_live.yunxin.live.audience.utils.LinkedSeatsAudienceActionManager
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_network_kt.network.ServiceCreator
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.BuildConfig
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import java.util.*

/**
 * 观众端页面 activity
 *
 *
 * 页面具体信息展示以及相关逻辑控制详细见 [BaseAudienceContentView]
 */
class LiveAudienceActivity : BaseActivity() {
    /**
     * 当前视频流位置
     */
    private var currentPosition = 0

    /**
     * 观众端竖直翻页 LayoutManager
     */
    private val layoutManager by lazy {
        PagerVerticalLayoutManager(this)
    }
    private var infoList: MutableList<LiveInfo>? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 屏幕常亮
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        // 使用 TextureView 添加硬件加速设置
        window.addFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED)
        setContentView(R.layout.activity_live_audience)
        infoList = intent.getSerializableExtra(KEY_PARAM_LIVE_INFO_LIST) as MutableList<LiveInfo>?
        // 初始化内部 view 以及相关控制逻辑
        initViews(infoList)
        //TODO （接入统一登录之后优化）
        ServiceCreator.setToken(NetworkClient.getInstance().accessToken)
        LiveRoomService.sharedInstance().setupWithOptions(this,BuildConfig.APP_KEY)
    }

    private fun initViews(infoList: MutableList<LiveInfo>?) {
        val rvAnchorList = findViewById<RecyclerView?>(R.id.rv_anchor_list)
        // 页面竖直滚动监听
        layoutManager.setOnPageChangedListener(object : OnPageChangedListener {
            override fun onPageInit(position: Int) {
                // 当页面处于部分可见时即会回调
                ALog.e("=====>", "init $position")
                currentPosition = position
                val itemView = layoutManager.findViewByPosition(position)
                if (itemView is BaseAudienceContentView) {
                    itemView.prepare()
                }
            }

            override fun onPageSelected(position: Int, isLimit: Boolean) {
                // 当页面完全可见时回调
                ALog.e("=====>", "selected $position, isLimit $isLimit")
                if (isLimit) {
                    ToastUtils.showShort(R.string.biz_live_have_no_more)
                    return
                }
                val itemView = layoutManager.findViewByPosition(position)
                if (itemView is BaseAudienceContentView) {
                    if (infoList == null || infoList.isEmpty()) {
                        return
                    }
                    (itemView as BaseAudienceContentView?)?.select(infoList[position].live.roomId)
                }
            }

            override fun onPageRelease(position: Int) {
                // 页面不可见时回调
                ALog.e("=====>", "release $position")
                val itemView = layoutManager.findViewByPosition(position)
                if (itemView is BaseAudienceContentView) {
                    itemView.release()
                }
            }
        })
        rvAnchorList.layoutManager = layoutManager
        val adapter = infoList?.let { LiveAnchorListAdapter(this, it) }
        rvAnchorList.adapter = adapter
        // 定位到直播间指定列表
        val currentPosition = intent.getIntExtra(KEY_PARAM_LIVE_INFO_POSITION, -1)
        if (currentPosition >= 0 && currentPosition < infoList!!.size) {
            layoutManager.scrollToPosition(currentPosition)
        }
        // 初始化直播间左右滑动页面位置
        ExtraTransparentView.initPosition()
    }

    override fun provideStatusBarConfig(): StatusBarConfig {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .build()
    }

    override fun finish() {
        // 页面销毁时资源释放，由于页面直接销毁时不会回调最后一个页面的 onPageRelease 所以在此处进行最后资源的释放；
        if (currentPosition >= 0) {
            val itemView = layoutManager.findViewByPosition(currentPosition)
            if (itemView is BaseAudienceContentView) {
                (itemView as BaseAudienceContentView?)?.release()
            }
            LinkedSeatsAudienceActionManager.destoryInstance()
            LiveRoomService.destroyInstance()
        }
        ALog.flush(true)
        super.finish()
    }

    companion object {
        /**
         * 传递至观众端页面的主播信息列表
         */
        private const val KEY_PARAM_LIVE_INFO_LIST: String = "live_info_list"

        /**
         * 传递当前选中主播在列表中的位置
         */
        private const val KEY_PARAM_LIVE_INFO_POSITION: String = "live_info_position"

        /**
         * 启动观众页面
         *
         * @param context  上下文
         * @param infoList 主播列表信息
         * @return 是否成功启动
         */
        fun launchAudiencePage(
            context: Context?,
            infoList: ArrayList<LiveInfo>?,
            position: Int
        ): Boolean {
            if (infoList == null || infoList.isEmpty()) {
                return false
            }
            val intent = Intent(context, LiveAudienceActivity::class.java)
            intent.putExtra(KEY_PARAM_LIVE_INFO_LIST, infoList)
            intent.putExtra(KEY_PARAM_LIVE_INFO_POSITION, position)
            if (context !is Activity) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context?.startActivity(intent)
            return true
        }
    }
}