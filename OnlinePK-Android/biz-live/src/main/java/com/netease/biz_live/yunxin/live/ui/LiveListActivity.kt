/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.os.Bundle
import android.text.TextUtils
import android.view.*
import android.widget.*
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.GridLayoutManager.SpanSizeLookup
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.ItemDecoration
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.adapter.LiveListAdapter
import com.netease.biz_live.yunxin.live.anchor.ui.AnchorPkLiveActivity
import com.netease.biz_live.yunxin.live.anchor.ui.AnchorSeatLiveActivity
import com.netease.biz_live.yunxin.live.audience.ui.LiveAudienceActivity
import com.netease.biz_live.yunxin.live.floatplay.FloatPlayManager
import com.netease.biz_live.yunxin.live.model.response.LiveListResponse
import com.netease.biz_live.yunxin.live.network.LiveInteraction
import com.netease.biz_live.yunxin.live.ui.widget.FooterView
import com.netease.biz_live.yunxin.live.ui.widget.HeaderView
import com.netease.biz_live.yunxin.live.utils.ClickUtils
import com.netease.biz_live.yunxin.live.utils.SpUtils
import com.netease.yunxin.android.lib.network.common.BaseResponse
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.listener.OnLoadMoreListener
import com.scwang.smart.refresh.layout.listener.OnRefreshListener
import io.reactivex.observers.ResourceSingleObserver
import java.util.*

/**
 * 直播列表页面
 */
class LiveListActivity : BaseActivity(), OnRefreshListener, OnLoadMoreListener {
    private var recyclerView: RecyclerView? = null
    private var llyCreateLive: LinearLayout? = null
    private var refreshLayout: SmartRefreshLayout? = null
    private val rlyEmpty: RelativeLayout? = null
    private var liveListAdapter: LiveListAdapter? = null
    private var ivClose: ImageView? = null

    private var type:Int = Constants.LiveType.LIVE_TYPE_PK

    //页码
    private var haveMore = false

    // 下一页请求页码
    private var nextPageNum = 1
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.live_list_activity_layout)
        paddingStatusBarHeight(R.id.rl_root)
        initView()
    }

    private fun initView() {
        val title = intent.getStringExtra(KEY_PARAM_TITLE)
        type = intent.getIntExtra(KEY_PARAM_TYPE,Constants.LiveType.LIVE_TYPE_PK)
        val tvTitle = findViewById<TextView?>(R.id.tv_title)
        tvTitle.text = if (TextUtils.isEmpty(title)) getString(R.string.biz_live_pk_live) else title
        recyclerView = findViewById(R.id.rcv_live)
        llyCreateLive = findViewById(R.id.lly_new_live)
        refreshLayout = findViewById(R.id.refreshLayout)
        ivClose = findViewById(R.id.iv_back)
        refreshLayout?.setRefreshHeader(HeaderView(this))
        refreshLayout?.setRefreshFooter(FooterView(this))
        refreshLayout?.setOnRefreshListener(this)
        refreshLayout?.setOnLoadMoreListener(this)
        llyCreateLive?.setOnClickListener {
            if (FloatPlayManager.isStartFloatWindow){
                FloatPlayManager.closeFloatPlay()
            }
            if (!ClickUtils.isFastClick()) {
                if (type == Constants.LiveType.LIVE_TYPE_PK) {
                    AnchorPkLiveActivity.startActivity(this)
                } else if (type == Constants.LiveType.LIVE_TYPE_SEAT) {
                    AnchorSeatLiveActivity.startActivity(this)
                }
            }
        }
        ivClose?.setOnClickListener { onBackPressed() }
        liveListAdapter = LiveListAdapter(this)
        liveListAdapter?.setOnItemClickListener(object :LiveListAdapter.OnItemClickListener {


            override fun onItemClick(liveList: ArrayList<LiveInfo>, position: Int) {
                //goto audience page
                if (!ClickUtils.isFastClick()) {
                    LiveAudienceActivity.launchAudiencePage(this@LiveListActivity, liveList, position)
                }
            }
        })
        val gridLayoutManager = GridLayoutManager(this, 2)
        val pixel8 = SpUtils.dp2pix(applicationContext, 8f)
        val pixel4 = SpUtils.dp2pix(applicationContext, 4f)
        recyclerView?.addItemDecoration(object : ItemDecoration() {
            override fun getItemOffsets(
                outRect: Rect,
                view: View,
                parent: RecyclerView,
                state: RecyclerView.State
            ) {
                val position = parent.getChildAdapterPosition(view)
                val left: Int
                val right: Int
                if (position % 2 == 0) {
                    left = pixel8
                    right = pixel4
                } else {
                    left = pixel4
                    right = pixel8
                }
                outRect[left, pixel4, right] = pixel4
            }
        })
        gridLayoutManager.spanSizeLookup = object : SpanSizeLookup() {
            override fun getSpanSize(position: Int): Int {
                // 如果是空布局，让它占满一行
                return if (liveListAdapter?.isEmptyPosition(position) == true) {
                    gridLayoutManager.spanCount
                } else 1
            }
        }
        recyclerView?.layoutManager = gridLayoutManager
        recyclerView?.adapter = liveListAdapter
    }

    override fun onResume() {
        super.onResume()
        initData()
    }

    private fun initData() {
        getLiveLists(true)
    }

    private fun getLiveLists(isRefresh: Boolean) {
        if(isRefresh){
            nextPageNum = 1
        }
        LiveInteraction.getLiveList(type, null,nextPageNum, PAGE_SIZE)
            .subscribe(object : ResourceSingleObserver<BaseResponse<LiveListResponse?>?>() {
                override fun onSuccess(liveListResponseBaseResponse: BaseResponse<LiveListResponse?>) {
                    if (liveListResponseBaseResponse.code == 200) {
                        nextPageNum++
                        if (liveListAdapter != null) {
                            liveListAdapter?.setDataList(
                                liveListResponseBaseResponse.data?.list,
                                isRefresh
                            )
                        }
                        haveMore = liveListResponseBaseResponse.data?.hasNextPage == true
                        if (isRefresh) {
                            refreshLayout?.finishRefresh(true)
                        } else {
                            if (liveListResponseBaseResponse.data?.list == null || liveListResponseBaseResponse.data?.list?.size == 0) {
                                refreshLayout?.finishLoadMoreWithNoMoreData()
                            } else {
                                refreshLayout?.finishLoadMore(true)
                            }
                        }
                    }
                }

                override fun onError(e: Throwable) {
                    if (isRefresh) {
                        refreshLayout?.finishRefresh(false)
                    } else {
                        refreshLayout?.finishLoadMore(false)
                    }
                }
            })
    }

    override fun onLoadMore(refreshLayout: RefreshLayout) {
        if (!haveMore) {
            refreshLayout.finishLoadMoreWithNoMoreData()
        } else {
            getLiveLists(false)
        }
    }

    override fun onRefresh(refreshLayout: RefreshLayout) {
        nextPageNum = 1
        getLiveLists(true)
    }

    override fun provideStatusBarConfig(): StatusBarConfig {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .statusBarColor(R.color.color_1a1a24)
            .build()
    }

    companion object {
        /**
         * intent 传递的 title 字段 key
         */
        private const val KEY_PARAM_TITLE: String = "key_param_title"

        private const val KEY_PARAM_TYPE  = "key_param_type"

        //每页大小
        private const val PAGE_SIZE = 20

        /**
         * 直播列表页面启动
         *
         * @param context 上下文
         * @param title 列表页面 title
         * @param type 类型
         */
        fun launchLiveList(context: Context, title: String, type: Int) {
            val intent = Intent(context, LiveListActivity::class.java)
            intent.putExtra(KEY_PARAM_TITLE, title)
            intent.putExtra(KEY_PARAM_TYPE,type)
            if (context !is Activity) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        }
    }
}