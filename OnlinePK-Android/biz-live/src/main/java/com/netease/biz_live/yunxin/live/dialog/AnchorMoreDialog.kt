/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.dialog

import android.app.Activity
import android.graphics.Color
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.Utils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter
import com.netease.biz_live.yunxin.live.audience.ui.dialog.BottomBaseDialog
import com.netease.biz_live.yunxin.live.utils.SpUtils

/**
 * 主播端底部更多弹窗
 */
class AnchorMoreDialog(activity: Activity) : BottomBaseDialog(activity) {
    protected var clickListener: OnItemClickListener? = null
    fun registerOnItemClickListener(listener: OnItemClickListener): AnchorMoreDialog {
        clickListener = listener
        return this
    }

    fun updateData(item: MoreItem?) {
        if (itemList.isEmpty()) {
            return
        }
        for (itemStep in itemList) {
            if (itemStep.id == item?.id) {
                itemStep.enable = item.enable
            }
        }
    }

    fun getData(): List<MoreItem> {
        return itemList
    }

    override fun renderTopView(parent: FrameLayout) {
        val titleView = TextView(context)
        titleView.setText(R.string.biz_live_more)
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16f)
        titleView.gravity = Gravity.CENTER
        titleView.setTextColor(Color.parseColor("#ff333333"))
        val layoutParams = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        parent.addView(titleView, layoutParams)
    }

    override fun renderBottomView(parent: FrameLayout) {
        val rvList = RecyclerView(context)
        rvList.overScrollMode = RecyclerView.OVER_SCROLL_NEVER
        val layoutParams = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, SpUtils.dp2pix(
                context, 222f
            )
        )
        parent.addView(rvList, layoutParams)
        rvList.layoutManager = GridLayoutManager(context, 4)
        rvList.adapter = object : LiveBaseAdapter<MoreItem>(context, itemList) {
            override fun getLayoutId(viewType: Int): Int {
                return R.layout.view_item_dialog_bottom_more
            }

            override fun onCreateViewHolder(itemView: View): LiveViewHolder {
                return LiveViewHolder(itemView)
            }

            override fun onBindViewHolder(holder: LiveViewHolder, itemData: MoreItem) {
                val ivIcon = holder.getView<ImageView?>(R.id.iv_item_icon)
                ivIcon?.setImageResource(itemData.iconResId)
                ivIcon?.isEnabled = itemData.enable
                val tvName = holder.getView<TextView?>(R.id.tv_item_name)
                tvName?.text = itemData.name
                holder.itemView.setOnClickListener { v: View? ->
                    clickListener?.let {
                        if (it.onItemClick(v, itemData)) {
                            itemData.enable = ivIcon?.isEnabled == false
                            ivIcon?.isEnabled = itemData.enable
                            updateData(itemData)
                        }
                    }
                    dismiss()
                }
            }
        }
    }

    class MoreItem(var id: Int, var iconResId: Int, var name: String?) {
        var enable = true
        fun setEnable(enable: Boolean): MoreItem {
            this.enable = enable
            return this
        }
    }

    interface OnItemClickListener {
        fun onItemClick(itemView: View?, item: MoreItem?): Boolean
    }

    companion object {
        const val ITEM_CAMERA = 1
        const val ITEM_MUTE = 2
        const val ITEM_RETURN = 3
        const val ITEM_CAMERA_SWITCH = 4
        const val ITEM_SETTING = 5
        const val ITEM_DATA = 6
        const val ITEM_FINISH = 7
        const val ITEM_FILTER = 8
        val itemList = listOf(
            MoreItem(
                ITEM_CAMERA,
                R.drawable.selector_more_camera_status,
                Utils.getApp().getString(R.string.biz_live_camera_text)
            ),
            MoreItem(
                ITEM_MUTE,
                R.drawable.selector_more_voice_status,
                Utils.getApp().getString(R.string.biz_live_microphone_text)
            ),
            MoreItem(
                ITEM_RETURN,
                R.drawable.selector_more_ear_return_status,
                Utils.getApp().getString(R.string.biz_live_earback)
            ).setEnable(false),
            MoreItem(
                ITEM_CAMERA_SWITCH,
                R.drawable.icon_camera_flip,
                Utils.getApp().getString(R.string.biz_live_flip)
            ),
            MoreItem(
                ITEM_FILTER,
                R.drawable.icon_filter_more,
                Utils.getApp().getString(R.string.biz_live_filter_text)
            ),
            MoreItem(
                ITEM_FINISH,
                R.drawable.icon_live_finish,
                Utils.getApp().getString(R.string.biz_live_end_live)
            )
        ).toMutableList()

        fun clearItem() {
            for (item in itemList) {
                if (item.id == ITEM_RETURN) {
                    item.setEnable(false)
                } else {
                    item.setEnable(true)
                }
            }
        }
    }
}