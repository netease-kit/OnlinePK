/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.feedback

import android.content.Context
import android.view.View
import android.widget.TextView
import com.netease.yunxin.nertc.demo.R
import com.netease.yunxin.nertc.demo.list.CommonAdapter

/**
 * Created by luc on 2020/11/19.
 */
internal class DemoNameAdapter(
    context: Context?,
    var focusedItem: String?,
    dataSource: List<String>?
) : CommonAdapter<String>(context, dataSource) {
    override fun getLayoutId(viewType: Int): Int {
        return R.layout.view_item_feedback_child
    }

    override fun onCreateViewHolder(itemView: View, viewType: Int): ItemViewHolder {
        return ItemViewHolder(itemView)
    }

    override fun onBindViewHolder(holder: ItemViewHolder, itemData: String) {
        val tvName = holder.getView<TextView>(R.id.tv_item_name)
        tvName!!.text = itemData
        val ivChosen = holder.getView<View>(R.id.iv_chosen_icon)
        ivChosen!!.visibility = if (focusedItem == itemData) View.VISIBLE else View.GONE
        holder.itemView.setOnClickListener { v: View? ->
            focusedItem = itemData
            notifyDataSetChanged()
        }
    }
}