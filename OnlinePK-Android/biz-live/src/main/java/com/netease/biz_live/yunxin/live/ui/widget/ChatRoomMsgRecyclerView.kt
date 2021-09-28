/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui.widget

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.ViewConfiguration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.netease.biz_live.yunxin.live.audience.adapter.ChatMsgListAdapter

/**
 * Created by luc on 2020/11/11.
 */
class ChatRoomMsgRecyclerView : RecyclerView {
    private val chatMsgListAdapter by lazy { ChatMsgListAdapter(context, ArrayList()) }
    private val layoutManager by lazy { LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false) }
    private var isTouching = false
    private var lastX = 0f
    private var lastY = 0f
    private var touchSlop = 0

    constructor(context: Context) : super(context) {
        init()
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        init()
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        init()
    }

    private fun init() {
        touchSlop = ViewConfiguration.get(context).scaledTouchSlop
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        setLayoutManager(layoutManager)
        adapter = chatMsgListAdapter
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        setLayoutManager(null)
        adapter = null
    }

    fun appendItem(sequence: CharSequence?) {
        chatMsgListAdapter.appendItem(sequence)
        toLatestMsg()
    }

    fun appendItems(sequenceList: MutableList<CharSequence?>?) {
        chatMsgListAdapter.appendItems(sequenceList)
        toLatestMsg()
    }

    fun toLatestMsg() {
        if (!isTouching) {
            layoutManager.scrollToPosition(chatMsgListAdapter.itemCount - 1)
        }
    }

    fun clearAllInfo() {
        if (chatMsgListAdapter != null) {
            chatMsgListAdapter.clearAll()
        }
    }

    /**
     * 滑动冲突处理，目前并不完善，横向滑动出现丢失，落点坐标未更新
     */
    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        when (ev.action) {
            MotionEvent.ACTION_DOWN -> {
                lastX = ev.x
                lastY = ev.y
                isTouching = true
                parent.requestDisallowInterceptTouchEvent(true)
            }
            MotionEvent.ACTION_MOVE -> {
                val currentX = ev.x
                val currentY = ev.y
                val resultX = currentX - lastX
                val resultY = currentY - lastY
                parent.requestDisallowInterceptTouchEvent(
                    Math.abs(resultX) <= touchSlop || Math.abs(resultY) >= touchSlop
                )
            }
            MotionEvent.ACTION_CANCEL, MotionEvent.ACTION_UP -> {
                isTouching = false
                parent.requestDisallowInterceptTouchEvent(false)
            }
        }
        return super.dispatchTouchEvent(ev)
    }
}