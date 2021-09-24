/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui.widget

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.ViewGroup
import android.widget.ImageView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter.LiveViewHolder
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.lib_live_room_service.bean.LiveUser
import java.util.*

/**
 * Created by luc on 2020/11/23.
 */
class AudiencePortraitRecyclerView : RecyclerView {
    private val layoutManager by lazy { LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false) }
    private val adapter by lazy { InnerAdapter(
        context
    ) }

    constructor(context: Context) : super(context)

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        setLayoutManager(layoutManager)
        setAdapter(adapter)
        overScrollMode = OVER_SCROLL_NEVER
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        setLayoutManager(null)
        setAdapter(null)
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        when (ev.action) {
            MotionEvent.ACTION_DOWN -> parent.requestDisallowInterceptTouchEvent(true)
            MotionEvent.ACTION_CANCEL, MotionEvent.ACTION_UP -> parent.requestDisallowInterceptTouchEvent(
                false
            )
        }
        return super.dispatchTouchEvent(ev)
    }

    fun addItem(audience: LiveUser) {
        adapter.addItem(audience)
    }

    fun addItems(audienceList: MutableList<LiveUser>?) {
        adapter.addItems(audienceList)
    }

    fun removeItem(audience: LiveUser?) {
        adapter.removeItem(audience)
    }

    fun updateAll(audienceList: MutableList<LiveUser>) {
        adapter.clear()
        addItems(audienceList)
    }

    private class InnerAdapter(private val context: Context?) : Adapter<LiveViewHolder?>() {
        private val dataSource: MutableList<LiveUser> = ArrayList()
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): LiveViewHolder {
            return LiveViewHolder(
                LayoutInflater.from(context)
                    .inflate(R.layout.view_item_audience_portrait_layout, parent, false)
            )
        }

        override fun onBindViewHolder(holder: LiveViewHolder, position: Int) {
            val ivPortrait = holder.getView<ImageView?>(R.id.iv_item_audience_portrait)
            val info = dataSource[position]
            ImageLoader.with(context).circleLoad(info.avatar, ivPortrait)
        }

        override fun getItemCount(): Int {
            return Math.min(dataSource.size, MAX_SHOWN_COUNT)
        }

        fun addItem(audience: LiveUser) {
            dataSource.add(audience)
            notifyDataSetChanged()
        }

        fun addItems(audienceList: MutableList<LiveUser>?) {
            if (audienceList == null) {
                return
            }
            dataSource.addAll(audienceList)
            notifyDataSetChanged()
        }

        fun removeItem(audience: LiveUser?) {
            if (dataSource.remove(audience)) {
                notifyDataSetChanged()
            }
        }

        fun clear() {
            dataSource.clear()
        }
    }

    companion object {
        private const val MAX_SHOWN_COUNT = 10
    }
}