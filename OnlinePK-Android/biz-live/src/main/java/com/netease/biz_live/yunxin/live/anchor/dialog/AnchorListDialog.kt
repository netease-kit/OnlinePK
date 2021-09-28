/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.dialog

import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.ScreenUtils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.anchor.dialog.adapter.AnchorListAdapter
import com.netease.biz_live.yunxin.live.dialog.BaseBottomDialog
import com.netease.biz_live.yunxin.live.model.response.LiveListResponse
import com.netease.biz_live.yunxin.live.network.LiveInteraction
import com.netease.biz_live.yunxin.live.ui.widget.FooterView
import com.netease.yunxin.android.lib.network.common.BaseResponse
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.listener.OnLoadMoreListener
import io.reactivex.observers.ResourceSingleObserver

/**
 * 主播列表，供PK选择
 */
class AnchorListDialog : BaseBottomDialog(), OnLoadMoreListener {
    private var rcyAnchor: RecyclerView? = null
    private var refreshLayout: SmartRefreshLayout? = null
    private var anchorListAdapter: AnchorListAdapter? = null

    // 下一页请求页码
    private var nextPageNum = 1

    //页码
    private var haveMore = false
    private var selectAnchorListener: SelectAnchorListener? = null
    override fun getResourceLayout(): Int {
        return R.layout.anchor_list_dialog_layout
    }

    override fun initView(rootView: View) {
        rcyAnchor = rootView.findViewById(R.id.rcv_anchor)
        refreshLayout = rootView.findViewById(R.id.refreshLayout)
        super.initView(rootView)
    }

    override fun initData() {
        nextPageNum = 1
        refreshLayout?.setEnableRefresh(false)
        refreshLayout?.setRefreshFooter(FooterView(context))
        refreshLayout?.setOnLoadMoreListener(this)
        val linearLayoutManager = LinearLayoutManager(context)
        rcyAnchor?.layoutManager = linearLayoutManager
        anchorListAdapter = AnchorListAdapter(context)
        anchorListAdapter?.setOnItemClickListener(object: AnchorListAdapter.OnItemClickListener{
            override fun onItemClick(liveInfo: LiveInfo) {
                dismiss()
                selectAnchorListener?.onAnchorSelect(liveInfo)
            }

        })
        rcyAnchor?.adapter = anchorListAdapter
        getAnchor()
        super.initData()
    }

    fun setSelectAnchorListener(selectAnchorListener: SelectAnchorListener?) {
        this.selectAnchorListener = selectAnchorListener
    }

    /**
     * 获取主播
     */
    private fun getAnchor() {
        LiveInteraction.getLiveList(Constants.LiveType.LIVE_TYPE_PK,Constants.LiveStatus.LIVE_STATUS_LIVING, nextPageNum, PAGE_SIZE)
            .subscribe(object : ResourceSingleObserver<BaseResponse<LiveListResponse?>?>() {
                override fun onSuccess(liveListResponseBaseResponse: BaseResponse<LiveListResponse?>) {
                    if (liveListResponseBaseResponse.code == 200) {
                        nextPageNum++
                        anchorListAdapter?.setDataList(liveListResponseBaseResponse.data?.list!!)

                        haveMore = liveListResponseBaseResponse.data?.hasNextPage == true
                        if (liveListResponseBaseResponse.data?.list == null || liveListResponseBaseResponse.data?.list?.size == 0) {
                            refreshLayout?.finishLoadMoreWithNoMoreData()
                        } else {
                            refreshLayout?.finishLoadMore(true)
                        }
                    }
                }

                override fun onError(e: Throwable) {
                    refreshLayout?.finishLoadMore(false)
                }
            })
    }

    override fun initParams() {
        val window = dialog?.window
        window?.let {
            it.setBackgroundDrawableResource(R.drawable.white_corner_bottom_dialog_bg)
            val params = it.attributes
            params.gravity = Gravity.BOTTOM
            // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
            params.width = ViewGroup.LayoutParams.MATCH_PARENT
            params.height = ScreenUtils.getScreenHeight() / 2
            it.attributes = params
        }
        isCancelable = true //设置点击外部是否消失
    }

    override fun onLoadMore(refreshLayout: RefreshLayout) {
        if (!haveMore) {
            refreshLayout.finishLoadMoreWithNoMoreData()
        } else {
            getAnchor()
        }
    }

    interface SelectAnchorListener {
        fun onAnchorSelect(liveInfo: LiveInfo)
    }

    companion object {
        //每页大小
        private const val PAGE_SIZE = 20
    }
}