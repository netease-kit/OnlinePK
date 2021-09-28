/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.dialog

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.Rect
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.ItemDecoration
import com.blankj.utilcode.util.Utils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter
import com.netease.biz_live.yunxin.live.gift.GiftCache
import com.netease.biz_live.yunxin.live.gift.GiftInfo
import com.netease.biz_live.yunxin.live.utils.SpUtils

class GiftDialog(activity: Activity) : BottomBaseDialog(activity) {
    private var sendListener: GiftSendListener? = null
    private val itemDecoration: ItemDecoration = object : ItemDecoration() {
        override fun getItemOffsets(
            outRect: Rect,
            view: View,
            parent: RecyclerView,
            state: RecyclerView.State
        ) {
            if (parent.getChildAdapterPosition(view) == 0) {
                outRect[SpUtils.dp2pix(context, 16f), 0, 0] = 0
            } else {
                super.getItemOffsets(outRect, view, parent, state)
            }
        }
    }

    override fun renderTopView(parent: FrameLayout) {
        val titleView = TextView(context)
        titleView.setText(R.string.biz_live_send_gift)
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
        val bottomView =
            LayoutInflater.from(context).inflate(R.layout.view_dialog_bottom_gift, parent)
        // 礼物列表初始化
        val rvGiftList: RecyclerView = bottomView.findViewById(R.id.rv_dialog_gift_list)
        rvGiftList.layoutManager =
            LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        rvGiftList.removeItemDecoration(itemDecoration)
        rvGiftList.addItemDecoration(itemDecoration)
        val adapter = InnerAdapter(
            context, GiftCache.getGiftList()
        )
        rvGiftList.adapter = adapter

        // 发送礼物
        val sendGift = bottomView.findViewById<View?>(R.id.tv_dialog_send_gift)
        sendGift.setOnClickListener {
            sendListener?.let {
                dismiss()
                sendListener?.onSendGift(adapter.getFocusedInfo()?.giftId)
            }
        }
    }

    /**
     * 弹窗展示
     *
     * @param listener 礼物发送回调
     */
    fun show(listener: GiftSendListener?) {
        sendListener = listener
        show()
    }

    /**
     * 礼物发送回调
     */
    interface GiftSendListener {
        open fun onSendGift(giftId: Int?)
    }

    /**
     * 内部礼物列表 adapter
     */
    private class InnerAdapter(context: Context?, dataSource: MutableList<GiftInfo>?) :
        LiveBaseAdapter<GiftInfo>(context, dataSource) {
        private var focusedInfo: GiftInfo? = null
        override fun getLayoutId(viewType: Int): Int {
            return R.layout.view_item_dialog_gift
        }

        override fun onCreateViewHolder(itemView: View): LiveViewHolder {
            return LiveViewHolder(itemView)
        }

        override fun onBindViewHolder(holder: LiveViewHolder, itemData: GiftInfo) {
            val ivGift = holder.getView<ImageView>(R.id.iv_item_gift_icon)
            ivGift?.setImageResource(itemData.staticIconResId)
            val tvName = holder.getView<TextView?>(R.id.tv_item_gift_name)
            tvName?.text = itemData.name
            val tvValue = holder.getView<TextView?>(R.id.tv_item_gift_value)
            tvValue?.text =  formatValue(itemData.coinCount)
            val border = holder.getView<View?>(R.id.rl_item_border)
            if (itemData == focusedInfo) {
                border?.setBackgroundResource(R.drawable.layer_dialog_gift_chosen_bg)
            } else {
                border?.setBackgroundColor(Color.TRANSPARENT)
            }
            holder.itemView.setOnClickListener {
                focusedInfo = itemData
                notifyDataSetChanged()
            }
        }

        fun getFocusedInfo(): GiftInfo? {
            return focusedInfo
        }

        private fun formatValue(value: Long): String? {
            return "(" + value + Utils.getApp().getString(R.string.biz_live_coin) + ")"
        }

        init {
            if (dataSource?.isNullOrEmpty() == true) {
                focusedInfo = dataSource[0]
            }
        }
    }
}