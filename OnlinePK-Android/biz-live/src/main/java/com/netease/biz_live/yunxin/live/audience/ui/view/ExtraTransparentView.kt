/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Rect
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.PagerSnapHelper
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.SnapHelper

/**
 * Created by luc on 2020/11/19.
 *
 *
 * 自定义view 继承自 [RecyclerView] 且 child count 数目固定为 2；child 1 为空白页面；child 2 为信息展示页面
 */
@SuppressLint("ViewConstructor")
class ExtraTransparentView(context: Context, contentView: View) : RecyclerView(context) {
    private val snapHelper: SnapHelper = PagerSnapHelper()
    private val layoutManager by lazy {
        object : LinearLayoutManager(getContext(), RecyclerView.HORIZONTAL, false) {
            override fun requestChildRectangleOnScreen(
                parent: RecyclerView,
                child: View,
                rect: Rect,
                immediate: Boolean,
                focusedChildVisible: Boolean
            ): Boolean {
                return false
            }
        }
    }
    private val adapter by lazy {
        InnerAdapter(context, contentView)
    }
    private var selectedRunnable: Runnable? = null
    private val onChildAttachStateChangeListener: OnChildAttachStateChangeListener =
        object : OnChildAttachStateChangeListener {
            override fun onChildViewAttachedToWindow(view: View) {
                DEFAULT_SELECT_POSITION = layoutManager.getPosition(view)
                if (DEFAULT_SELECT_POSITION != 0) {
                    selectedRunnable?.run()
                }
            }

            override fun onChildViewDetachedFromWindow(view: View) {}
        }

    private fun initViews() {
        setLayoutManager(layoutManager)
        snapHelper.attachToRecyclerView(this)
        setAdapter(adapter)
        overScrollMode = OVER_SCROLL_NEVER
    }

    fun registerSelectedRunnable(selectedRunnable: Runnable?) {
        this.selectedRunnable = selectedRunnable
    }

    fun toSelectedPosition() {
        layoutManager.scrollToPosition(DEFAULT_SELECT_POSITION)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        addOnChildAttachStateChangeListener(onChildAttachStateChangeListener)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        removeOnChildAttachStateChangeListener(onChildAttachStateChangeListener)
    }

    private class InnerAdapter(
        private val context: Context?,
        private val contentView: View
    ) : Adapter<InnerViewHolder?>() {
        override fun getItemViewType(position: Int): Int {
            return if (position == 0) TYPE_TRANSPARENT else TYPE_CONTENT
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): InnerViewHolder {
            val holder: InnerViewHolder
            val itemView: View = if (viewType == TYPE_CONTENT) {
                    contentView
                } else {
                    View(context)
                }
            itemView.layoutParams = LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            holder = InnerViewHolder(itemView)
            return holder
        }

        override fun onBindViewHolder(holder: InnerViewHolder, position: Int) {}
        override fun getItemCount(): Int {
            return COUNT_TOTAL
        }

        companion object {
            private const val TYPE_TRANSPARENT = 0
            private const val TYPE_CONTENT = 1
            private const val COUNT_TOTAL = 2
        }
    }

    class InnerViewHolder(itemView: View) : ViewHolder(itemView)
    companion object {
        private var DEFAULT_SELECT_POSITION = 1
        fun initPosition() {
            DEFAULT_SELECT_POSITION = 1
        }
    }

    init {
        snapHelper.attachToRecyclerView(this)
        initViews()
    }
}