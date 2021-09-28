/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.utils.StringUtils
import com.netease.biz_live.yunxin.live.utils.SpUtils
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo

/**
 * 直播主界面直播列表adapter
 */
class LiveListAdapter(private val context: Context) :
    RecyclerView.Adapter<RecyclerView.ViewHolder?>() {
    private var liveInfos: ArrayList<LiveInfo> = ArrayList()
    private var onItemClickListener: OnItemClickListener? = null
    fun setOnItemClickListener(onItemClickListener: OnItemClickListener?) {
        this.onItemClickListener = onItemClickListener
    }

    // Live ViewHolder
    internal class LiveItemHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var ivRoomPic: ImageView = itemView.findViewById(R.id.iv_room_pic)
        var ivPkTag: ImageView = itemView.findViewById(R.id.iv_pk_tag)
        var tvAnchorName: TextView = itemView.findViewById(R.id.tv_anchor_name)
        var tvRoomName: TextView = itemView.findViewById(R.id.tv_room_name)
        var tvAudienceNum: TextView = itemView.findViewById(R.id.tv_audience_num)

    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        if (viewType == VIEW_TYPE_EMPTY) {
            val emptyView = LayoutInflater.from(parent.context)
                .inflate(R.layout.list_empty_layout, parent, false)
            return object : RecyclerView.ViewHolder(emptyView) {}
        }
        val rootView: View?
        rootView =
            LayoutInflater.from(parent.context).inflate(R.layout.live_item_layout, parent, false)
        return LiveItemHolder(rootView)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is LiveItemHolder) {
            val liveInfo = liveInfos[position]
            holder.tvRoomName.text = liveInfo.live.roomTopic
            holder.tvAnchorName.text = liveInfo.anchor.nickname
            holder.tvAudienceNum.text = StringUtils.getAudienceCount(liveInfo.live.audienceCount)
            ImageLoader.with(context.applicationContext)
                .roundedCorner(
                    liveInfo.live.cover,
                    SpUtils.dp2pix(context, 4f),
                    holder.ivRoomPic
                )
            if (liveInfo.live.liveStatus == Constants.LiveStatus.LIVE_STATUS_PKING ||
                liveInfo.live.liveStatus == Constants.LiveStatus.LIVE_STATUS_ON_PUNISHMENT) {
                holder.ivPkTag.visibility = View.VISIBLE
                holder.ivPkTag.setImageResource(R.drawable.pk_icon)
            } else if (liveInfo.live.liveStatus == Constants.LiveStatus.LIVE_STATUS_ON_SEAT) {
                holder.ivPkTag.visibility = View.VISIBLE
                holder.ivPkTag.setImageResource(R.drawable.icon_status_multi_micro)
            } else {
                holder.ivPkTag.visibility = View.GONE
            }
            holder.itemView.setOnClickListener {
                onItemClickListener?.onItemClick(liveInfos, position)
            }
        }
    }

    /**
     * 判断是否是空布局
     */
    fun isEmptyPosition(position: Int): Boolean {
        return position == 0 && liveInfos.isEmpty()
    }

    /**
     * 更新数据
     *
     * @param liveInfoList
     * @param isRefresh
     */
    fun setDataList(liveInfoList: MutableList<LiveInfo>?, isRefresh: Boolean) {
        if (isRefresh) {
            liveInfos.clear()
        }
        if (liveInfoList != null && liveInfoList.size != 0) {
            liveInfos.addAll(liveInfoList)
        }
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int {
        return if ( liveInfos.size > 0) {
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
        open fun onItemClick(liveList: ArrayList<LiveInfo>, position: Int)
    }

    companion object {
        const val VIEW_TYPE_ITEM = 1
        const val VIEW_TYPE_EMPTY = 0
    }

    init {
        liveInfos = ArrayList()
    }
}