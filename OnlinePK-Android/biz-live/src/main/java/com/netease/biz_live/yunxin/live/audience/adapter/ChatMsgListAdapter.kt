/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.adapter

import android.content.Context
import android.view.View
import android.widget.TextView
import com.netease.biz_live.R

/**
 * Created by luc on 2020/11/11.
 *
 *
 * 聊天室信息列表 adapter，主要追加信息时 定位到最后一条数据
 */
class ChatMsgListAdapter(context: Context?, dataSource: MutableList<CharSequence?>?) :
    LiveBaseAdapter<CharSequence?>(context, dataSource) {
    override fun getLayoutId(viewType: Int): Int {
        return R.layout.view_item_msg_content_layout
    }

    override fun onCreateViewHolder(itemView: View): LiveViewHolder {
        return LiveViewHolder(itemView)
    }

    override fun onBindViewHolder(holder: LiveViewHolder, itemData: CharSequence?) {
        val tvContent = holder.getView<TextView?>(R.id.tv_msg_content)
        tvContent?.text = itemData
    }

    fun appendItem(sequence: CharSequence?) {
        if (sequence == null) {
            return
        }
        dataSource.add(sequence)
        notifyItemInserted(dataSource.size - 1)
    }

    fun appendItems(sequenceList: MutableList<CharSequence?>?) {
        if (sequenceList == null || sequenceList.isEmpty()) {
            return
        }
        val start = itemCount
        dataSource.addAll(sequenceList)
        notifyItemRangeInserted(start, sequenceList.size)
    }

    fun clearAll() {
        dataSource.clear()
        notifyDataSetChanged()
    }
}