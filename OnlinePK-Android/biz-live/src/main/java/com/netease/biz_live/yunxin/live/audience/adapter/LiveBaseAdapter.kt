/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.adapter

import android.content.Context
import android.util.SparseArray
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter.LiveViewHolder
import java.util.*

abstract class LiveBaseAdapter<T> : RecyclerView.Adapter<LiveViewHolder?> {
    protected val dataSource: ArrayList<T> = ArrayList()
    protected val context: Context?

    constructor(context: Context?) {
        this.context = context
    }

    constructor(context: Context?, dataSource: MutableList<T>?) {
        this.context = context
        if (dataSource != null) {
            this.dataSource.addAll(dataSource)
        }
    }

    fun getDataSource(): MutableList<T> {
        return dataSource
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): LiveViewHolder {
        return onCreateViewHolder(
            LayoutInflater.from(context).inflate(getLayoutId(viewType), parent, false)
        )
    }

    protected abstract fun getLayoutId(viewType: Int): Int
    protected abstract fun onCreateViewHolder(itemView: View): LiveViewHolder
    override fun onBindViewHolder(holder: LiveViewHolder, position: Int) {
        val itemData = getItem(position) ?: return
        onBindViewHolder(holder, itemData, position)
    }

    protected open fun onBindViewHolder(holder: LiveViewHolder, itemData: T, position: Int) {
        onBindViewHolder(holder, itemData)
    }

    protected open fun onBindViewHolder(holder: LiveViewHolder, itemData: T) {}
    fun updateDataSource(newDataSource: List<T>?) {
        dataSource.clear()
        if (newDataSource?.isNotEmpty() == true) {
            dataSource.addAll(newDataSource)
        }
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int {
        return dataSource.size
    }

    protected fun getItem(position: Int): T? {
        return if (position < 0 || position >= itemCount) {
            null
        } else dataSource.get(position)
    }

    class LiveViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val viewCache: SparseArray<View?> = SparseArray()
        fun <T : View?> getView(viewId: Int): T? {
            var result = viewCache.get(viewId)
            if (result == null) {
                result = itemView.findViewById(viewId)
                viewCache.put(viewId, result)
            }
            return result as T
        }
    }
}