/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.content.Context
import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.PagerSnapHelper
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.OnChildAttachStateChangeListener
import androidx.recyclerview.widget.RecyclerView.Recycler
import androidx.recyclerview.widget.SnapHelper

/**
 * Created by luc on 2020/11/19.
 */
class PagerVerticalLayoutManager(context: Context?) :
    LinearLayoutManager(context, VERTICAL, false) {
    /**
     * 是否为recyclerview 首次加载数据
     */
    private var isFirstLoad = true

    /**
     * 子view attach window 状态变化
     */
    private val onChildAttachStateChangeListener: OnChildAttachStateChangeListener =
        object : OnChildAttachStateChangeListener {
            override fun onChildViewAttachedToWindow(view: View) {
                pageChangedListener?.onPageInit(getPosition(view))

                if (isFirstLoad) {
                    isFirstLoad = false
                    val position = getPosition(view)
                    lastPosition = position
                    if (pageChangedListener != null) {
                        pageChangedListener?.onPageSelected(position, false)
                        isLimit = true // 初始化位置认为此次滑动在端点
                    }
                }
            }

            override fun onChildViewDetachedFromWindow(view: View) {
                pageChangedListener?.onPageRelease(getPosition(view))
            }
        }
    private val snapHelper: SnapHelper?

    /**
     * 页面滚动回调
     */
    private var pageChangedListener: OnPageChangedListener? = null

    /**
     * 上一次selected 记录位置
     */
    private var lastPosition = -1

    /**
     * 标记是否为页面最前/最后的数据
     */
    private var isLimit = false

    // 避免请求焦点出现滚动；
    override fun requestChildRectangleOnScreen(
        parent: RecyclerView,
        child: View,
        rect: Rect,
        immediate: Boolean,
        focusedChildVisible: Boolean
    ): Boolean {
        return false
    }

    // 避免焦点请求失败导致页面重新填充，出现下一个view进行attach window 操作；
    override fun onFocusSearchFailed(
        focused: View,
        focusDirection: Int,
        recycler: Recycler,
        state: RecyclerView.State
    ): View? {
        return null
    }

    override fun onScrollStateChanged(state: Int) {
        if (state != RecyclerView.SCROLL_STATE_IDLE) {
            return
        }
        val currentView = snapHelper?.findSnapView(this) ?: return
        val position = getPosition(currentView)

        // 位置相同且判断不为首部/尾部数据滑动不进行回调
        if (position == lastPosition && !isLimit) {
            isLimit = true // 位置相同 则可能是首部/尾部数据
            return
        }
        if (pageChangedListener != null && childCount == 1) {
            pageChangedListener?.onPageSelected(position, isLimit)
        }
        lastPosition = position
        isLimit = true // 滑动时认为每个点都可能时端点数据
    }

    fun setOnPageChangedListener(pageChangedListener: OnPageChangedListener?) {
        this.pageChangedListener = pageChangedListener
    }

    override fun onAttachedToWindow(view: RecyclerView) {
        super.onAttachedToWindow(view)
        snapHelper?.attachToRecyclerView(view)
        view.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)
                isLimit = dy == 0 // 如果存在纵向滑动变化则说明不在端点
            }

        })
        view.addOnChildAttachStateChangeListener(onChildAttachStateChangeListener)
    }

    /**
     * 页面滑动监听
     */
    interface OnPageChangedListener {
        /**
         * 页面初始化完成
         *
         * @param position 页面position
         */
        open fun onPageInit(position: Int)

        /**
         * 页面滑动时调用
         *
         * @param position 当前页面位置
         * @param isLimit  是否为滑动方向的最后一条，端点判断逻辑，认为每次滑动后都到达了端点，但是通过 dy 修正是否真正到达端点；
         */
        open fun onPageSelected(position: Int, isLimit: Boolean)

        /**
         * 页面销毁时调用
         *
         * @param position 页面position
         */
        open fun onPageRelease(position: Int)
    }

    init {
        snapHelper = PagerSnapHelper()
    }
}