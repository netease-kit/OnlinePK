/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.list

import android.content.Context
import android.util.SparseArray
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.netease.yunxin.nertc.demo.list.CommonAdapter.ItemViewHolder
import java.util.*

abstract class CommonAdapter<T>(protected var context: Context?, dataSource: List<T>?) :
    RecyclerView.Adapter<ItemViewHolder>() {
    protected var dataSource: List<T>?
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        return onCreateViewHolder(
            LayoutInflater.from(context).inflate(getLayoutId(viewType), parent, false), viewType
        )
    }

    protected abstract fun getLayoutId(viewType: Int): Int
    protected abstract fun onCreateViewHolder(itemView: View, viewType: Int): ItemViewHolder
    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
        val itemData = getItem(position) ?: return
        onBindViewHolder(holder, itemData)
    }

    protected abstract fun onBindViewHolder(holder: ItemViewHolder, itemData: T)
    override fun getItemCount(): Int {
        return if (dataSource != null) dataSource!!.size else 0
    }

    protected fun getItem(position: Int): T? {
        return if (position < 0 || position >= itemCount) {
            null
        } else dataSource!![position]
    }

    class ItemViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val viewCache = SparseArray<View?>()
        fun <T : View?> getView(viewId: Int): T? {
            var result = viewCache[viewId]
            if (result == null) {
                result = itemView.findViewById(viewId)
                viewCache.put(viewId, result)
            }
            return result as T?
        }
    }

    init {
        this.dataSource = ArrayList(dataSource)
    }
}