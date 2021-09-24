/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.list

import android.content.Context
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.netease.yunxin.nertc.demo.R

class FunctionAdapter(context: Context?, dataSource: List<FunctionItem>?) :
    CommonAdapter<FunctionItem>(context, dataSource) {
    override fun getItemViewType(position: Int): Int {
        return getItem(position)!!.type
    }

    override fun getLayoutId(viewType: Int): Int {
        val layoutId: Int
        layoutId =
            if (viewType == TYPE_VIEW_CONTENT) {
                R.layout.view_item_function
            } else {
                R.layout.view_item_function_title
            }
        return layoutId
    }

    override fun onCreateViewHolder(itemView: View, viewType: Int): ItemViewHolder {
        return ItemViewHolder(itemView)
    }

    override fun onBindViewHolder(holder: ItemViewHolder, itemData: FunctionItem) {
        if (itemData.type == TYPE_VIEW_TITLE) {
            val ivIcon = holder.getView<ImageView>(R.id.iv_title_icon)
            ivIcon!!.setImageResource(itemData.iconResId)
            return
        }
        val ivIcon = holder.getView<ImageView>(R.id.iv_function_icon)
        ivIcon!!.setImageResource(itemData.iconResId)
        val tvName = holder.getView<TextView>(R.id.tv_function_name)
        tvName!!.text = itemData.nameStr
        val tvDesc = holder.getView<TextView>(R.id.tv_function_desc)
        tvDesc!!.text = itemData.descriptionStr
        holder.itemView.setOnClickListener { v: View? ->
            if (itemData.action != null) {
                itemData.action.run()
            }
        }
    }

    companion object {
        const val TYPE_VIEW_TITLE = 0
        const val TYPE_VIEW_CONTENT = 1
    }
}