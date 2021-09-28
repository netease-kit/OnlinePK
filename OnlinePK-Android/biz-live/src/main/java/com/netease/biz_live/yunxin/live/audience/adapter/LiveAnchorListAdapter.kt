/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.netease.biz_live.yunxin.live.audience.adapter.LiveAnchorListAdapter.ListViewHolder
import com.netease.biz_live.yunxin.live.audience.ui.view.BaseAudienceContentView
import com.netease.biz_live.yunxin.live.audience.ui.view.PkAudienceContentView
import com.netease.biz_live.yunxin.live.audience.ui.view.SeatAudienceContentView
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.nertc.demo.basic.BaseActivity

/**
 * Created by luc on 2020/11/9.
 *
 *
 * 观众页面展示主播信息的 adapter
 */
class LiveAnchorListAdapter(
    private val activity: BaseActivity,
    dataSource: MutableList<LiveInfo>
) : RecyclerView.Adapter<ListViewHolder?>() {
    private val liveInfoList: MutableList<LiveInfo> = dataSource
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ListViewHolder {
        val itemView = if(viewType == Constants.LiveType.LIVE_TYPE_PK){
            PkAudienceContentView(activity)
        } else{
            SeatAudienceContentView(activity)
        }
        val layoutParams = RecyclerView.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        itemView.layoutParams = layoutParams
        return ListViewHolder(itemView)
    }

    override fun onBindViewHolder(holder: ListViewHolder, position: Int) {
        holder.contentView.renderData(getItem(position))
    }

    override fun getItemCount(): Int {
        return liveInfoList.size
    }

    fun getItem(position: Int): LiveInfo {
        return liveInfoList.get(position)
    }

    override fun getItemViewType(position: Int): Int {
        val liveInfo = liveInfoList[position]
        return liveInfo.live.type
    }

    class ListViewHolder(itemView: BaseAudienceContentView) : RecyclerView.ViewHolder(itemView) {
        val contentView: BaseAudienceContentView = itemView

    }
}