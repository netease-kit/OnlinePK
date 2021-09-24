/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.dialog.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.Utils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.utils.StringUtils
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo

/**
 * 主播选择PK列表
 */
class AnchorListAdapter(private val context: Context?) :
    RecyclerView.Adapter<RecyclerView.ViewHolder?>() {
    private var liveInfos: ArrayList<LiveInfo> = ArrayList()
    private var onItemClickListener: OnItemClickListener? = null
    fun setOnItemClickListener(onItemClickListener: OnItemClickListener?) {
        this.onItemClickListener = onItemClickListener
    }

    // Live ViewHolder
    internal class LiveItemHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var ivAnchor: ImageView = itemView.findViewById(R.id.iv_anchor)
        var tvAnchorName: TextView = itemView.findViewById(R.id.tv_anchor_name)
        var tvAudienceNum: TextView = itemView.findViewById(R.id.tv_audience_num)
        var tvStartPk: TextView = itemView.findViewById(R.id.tv_start_pk)

    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        if (viewType == VIEW_TYPE_EMPTY) {
            val emptyView = LayoutInflater.from(parent.context)
                .inflate(R.layout.list_empty_layout, parent, false)
            emptyView.findViewById<View?>(R.id.iv_empty).alpha = 0.2f
            return object : RecyclerView.ViewHolder(emptyView) {}
        }
        val rootView: View = LayoutInflater.from(parent.context)
            .inflate(R.layout.anchor_list_item_layout, parent, false)
        return LiveItemHolder(rootView)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is LiveItemHolder) {
            val liveInfo = liveInfos[position]
            val liveItemHolder = holder
            liveItemHolder.tvAnchorName.text = liveInfo.anchor.nickname
            liveItemHolder.tvAudienceNum.text = Utils.getApp()
                .getString(R.string.biz_live_audience_count) + StringUtils.getAudienceCount(
                liveInfo.live.audienceCount
            )
            ImageLoader.with(context?.applicationContext)
                .circleLoad(liveInfo.anchor.avatar, liveItemHolder.ivAnchor)
            liveItemHolder.tvStartPk.setOnClickListener(View.OnClickListener { v: View? ->
                onItemClickListener?.onItemClick(liveInfo)
            })
        }
    }

    /**
     * 更新数据
     *
     * @param liveInfoList
     */
    fun setDataList(liveInfoList: MutableList<LiveInfo>) {
        if (liveInfoList.size != 0) {
            liveInfos.addAll(liveInfoList)
        }
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int {
        return if (liveInfos != null && liveInfos.size > 0) {
            liveInfos.size
        } else 1
    }

    override fun getItemViewType(position: Int): Int {
        //在这里进行判断，如果我们的集合的长度为0时，我们就使用emptyView的布局
        return if (liveInfos.size == 0) {
            VIEW_TYPE_EMPTY
        } else VIEW_TYPE_ITEM
        //如果有数据，则使用ITEM的布局
    }

    interface OnItemClickListener {
        open fun onItemClick(liveInfo: LiveInfo)
    }

    companion object {
        const val VIEW_TYPE_ITEM = 1
        const val VIEW_TYPE_EMPTY = 0
    }

    init {
        liveInfos = ArrayList()
    }
}