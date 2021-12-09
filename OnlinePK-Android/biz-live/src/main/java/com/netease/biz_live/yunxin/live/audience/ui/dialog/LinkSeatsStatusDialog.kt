/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.dialog

import android.content.Context
import android.graphics.Color
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter
import com.netease.biz_live.yunxin.live.audience.ui.view.DurationStatisticTimer
import com.netease.biz_live.yunxin.live.audience.utils.LinkedSeatsAudienceActionManager
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.login.sdk.AuthorManager
import com.netease.yunxin.seatlibrary.CompletionCallback
import com.netease.yunxin.seatlibrary.seat.constant.SeatAVState
import java.util.*

/**
 * @author sunkeding
 * 连麦状态弹窗
 */
class LinkSeatsStatusDialog(
    activity: FragmentActivity,
    private val linkedSeatsAudienceActionManager: LinkedSeatsAudienceActionManager
) : BottomBaseDialog(activity) {
    private var durationStatisticTimer: DurationStatisticTimer? = null
    private var adapter: InnerAdapter? = null
    override fun renderTopView(parent: FrameLayout) {
        val titleView = TextView(context)
        titleView.setText(R.string.biz_live_link_seats_status)
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
        val bottomView = LayoutInflater.from(context)
            .inflate(R.layout.view_dialog_bottom_microphone_status, parent)
        val recyclerView: RecyclerView = bottomView.findViewById(R.id.rv)
        recyclerView.layoutManager = GridLayoutManager(context, GRID_SPAN_COUNT)
        adapter = InnerAdapter(
            context, getButtonData()
        )
        recyclerView.adapter = adapter
        adapter?.setOptionClickListener(object : OptionClickListener {
            override fun clickBeauty() {
                linkedSeatsAudienceActionManager.showBeautySettingDialog(activity as FragmentActivity)
            }

            override fun clickFilter() {
                linkedSeatsAudienceActionManager.showFilterSettingDialog(activity as FragmentActivity)
            }

            override fun clickHangup() {
                linkedSeatsAudienceActionManager.leaveSeat(
                    object : CompletionCallback<Void> {
                        override fun success(info: Void?) {
                            if (isShowing) {
                                dismiss()
                            }
                        }

                        override fun error(code: Int, msg: String) {
                            if (isShowing) {
                                dismiss()
                            }
                        }
                    })
            }

            override fun clickCamere(iv: ImageView?) {
                linkedSeatsAudienceActionManager.switchCamera(iv)
            }

            override fun clickMicrophone(iv: ImageView?) {
                linkedSeatsAudienceActionManager.switchMicrophone(iv)
            }
        })
        durationStatisticTimer = bottomView.findViewById(R.id.tv_duration)
        val imageView = bottomView.findViewById<ImageView?>(R.id.iv)
        durationStatisticTimer?.start()
        ImageLoader.with(context.applicationContext)
            .circleLoad(
                AuthorManager.getUserInfo()!!.avatar, imageView
            )
    }

    private fun getButtonData(): MutableList<OptionButtonInfo> {
        val optionButtonInfos = ArrayList<OptionButtonInfo>()
        optionButtonInfos.add(
            OptionButtonInfo(
                OptionButtonInfo.ITEM_BEAUTY, R.drawable.biz_live_beauty, activity.getString(
                    R.string.biz_live_beauty_text
                )
            )
        )
        optionButtonInfos.add(
            OptionButtonInfo(
                OptionButtonInfo.ITEM_FILTER, R.drawable.biz_live_filter, activity.getString(
                    R.string.biz_live_filter_text
                )
            )
        )
        optionButtonInfos.add(
            OptionButtonInfo(
                OptionButtonInfo.ITEM_HANGUP, R.drawable.biz_live_hangup, activity.getString(
                    R.string.biz_live_hangup_text
                )
            )
        )
        optionButtonInfos.add(
            OptionButtonInfo(
                OptionButtonInfo.ITEM_CAMERA,
                if (LinkedSeatsAudienceActionManager.enableLocalVideo) R.drawable.biz_live_camera else R.drawable.biz_live_camera_close,
                activity.getString(
                    R.string.biz_live_camera_text
                )
            )
        )
        optionButtonInfos.add(
            OptionButtonInfo(
                OptionButtonInfo.ITEM_MICROPHOHE,
                if (LinkedSeatsAudienceActionManager.enableLocalAudio) R.drawable.biz_live_microphone else R.drawable.biz_live_microphone_close,
                activity.getString(
                    R.string.biz_live_microphone_text
                )
            )
        )
        return optionButtonInfos
    }

    override fun dismiss() {
        durationStatisticTimer?.stop()
        super.dismiss()
    }

    fun refreshLinkSeatDialog(position: Int, openState: Int) {
        if (position == CAMERA_POSITION) {
            adapter?.getDataSource()?.set(position, OptionButtonInfo(
                OptionButtonInfo.ITEM_CAMERA,
                if (openState == SeatAVState.OPEN) R.drawable.biz_live_camera else R.drawable.biz_live_camera_close,
                activity.getString(R.string.biz_live_camera_text)
            )
            )
        } else if (position == MICROPHONE_POSITION) {
            adapter?.getDataSource()?.set(position, OptionButtonInfo(
                OptionButtonInfo.ITEM_MICROPHOHE,
                if (openState == SeatAVState.OPEN) R.drawable.biz_live_microphone else R.drawable.biz_live_microphone_close,
                activity.getString(R.string.biz_live_microphone_text)
            )
            )
        }
        adapter?.notifyItemChanged(position)
    }

    /**
     * 操作按钮列表 adapter
     */
    private class InnerAdapter(context: Context?, dataSource: MutableList<OptionButtonInfo>) :
        LiveBaseAdapter<OptionButtonInfo>(context, dataSource) {
        private var optionClickListener: OptionClickListener? = null
        fun setOptionClickListener(optionClickListener: OptionClickListener?) {
            this.optionClickListener = optionClickListener
        }

        fun refresh(dataSource: MutableList<OptionButtonInfo>?) {
            updateDataSource(dataSource)
        }

        override fun getLayoutId(viewType: Int): Int {
            return R.layout.view_item_dialog_option_button
        }

        override fun onCreateViewHolder(itemView: View): LiveViewHolder {
            return LiveViewHolder(itemView)
        }

        override fun onBindViewHolder(holder: LiveViewHolder, itemData: OptionButtonInfo) {
            val iv = holder.getView<ImageView?>(R.id.iv)
            val tvName = holder.getView<TextView?>(R.id.tv)
            iv?.setImageResource(itemData.resId)
            tvName?.text = itemData.name
            holder.itemView.setOnClickListener { v: View? ->
                optionClickListener?.let {
                    when (itemData.id) {
                        0 -> it.clickBeauty()
                        1 -> it.clickFilter()
                        2 -> it.clickHangup()
                        3 -> it.clickCamere(iv)
                        4 -> it.clickMicrophone(iv)
                        else -> {
                        }
                    }
                }
            }
        }
    }

    private class OptionButtonInfo(var id: Int, var resId: Int, var name: String?) {
        companion object {
            const val ITEM_BEAUTY = 0
            const val ITEM_FILTER = 1
            const val ITEM_HANGUP = 2
            const val ITEM_CAMERA = 3
            const val ITEM_MICROPHOHE = 4
        }
    }

    interface OptionClickListener {
        open fun clickBeauty()
        open fun clickFilter()
        open fun clickHangup()
        open fun clickCamere(iv: ImageView?)
        open fun clickMicrophone(iv: ImageView?)
    }

    companion object {
        private const val GRID_SPAN_COUNT = 5
        const val CAMERA_POSITION = 3
        const val MICROPHONE_POSITION = 4
    }
}