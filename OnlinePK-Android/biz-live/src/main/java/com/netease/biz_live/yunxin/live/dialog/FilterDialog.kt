/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.dialog

import android.graphics.Color
import android.graphics.Rect
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.SeekBar
import android.widget.SeekBar.OnSeekBarChangeListener
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.ItemDecoration
import com.beautyFaceunity.FilterEnum
import com.beautyFaceunity.OnFUControlListener
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.dialog.FilterDialog.FilterRecyclerAdapter.HomeRecyclerHolder
import com.netease.biz_live.yunxin.live.utils.SpUtils
import com.netease.yunxin.android.lib.picture.ImageLoader
import java.util.*

/**
 * 滤镜控制dialog
 */
class FilterDialog : BaseBottomDialog() {
    private var seekBarSaturability //饱和度的拖动条
            : SeekBar? = null
    private var rcvFilter //滤镜
            : RecyclerView? = null
    private var ivReset //恢复
            : ImageView? = null

    //滤镜list
    private val mFilters by lazy { FilterEnum.getFiltersByFilterType() }
    private var mOnFUControlListener: OnFUControlListener? = null
    private var filterRecyclerAdapter: FilterRecyclerAdapter? = null
    fun setOnFUControlListener(onFUControlListener: OnFUControlListener) {
        mOnFUControlListener = onFUControlListener
        mOnFUControlListener?.onFilterNameSelected(sFilter.name)
        val level = getFilterLevel(sFilter.name)
        setFilterLevel(sFilter.name, level)
    }

    override fun getResourceLayout(): Int {
        return R.layout.filter_dialog_layout
    }

    override fun initView(rootView: View) {
        super.initView(rootView)
        seekBarSaturability = rootView.findViewById(R.id.sb_saturability)
        rcvFilter = rootView.findViewById(R.id.rcv_filter)
        ivReset = rootView.findViewById(R.id.iv_reset)
    }

    override fun initData() {
        super.initData()
        filterRecyclerAdapter = FilterRecyclerAdapter()
        rcvFilter?.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.HORIZONTAL,
            false
        )
        val padding = SpUtils.dp2pix(rcvFilter?.context!!, 20f)
        rcvFilter?.addItemDecoration(object : ItemDecoration() {
            override fun getItemOffsets(
                outRect: Rect,
                view: View,
                parent: RecyclerView,
                state: RecyclerView.State
            ) {
                super.getItemOffsets(outRect, view, parent, state)
                val index = parent.getChildAdapterPosition(view)
                outRect[padding, 0, if (index == (mFilters?.size?.minus(1))) padding else 0] = 0
            }
        })
        rcvFilter?.adapter = filterRecyclerAdapter
        rcvFilter?.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                recyclerView.layoutManager?.let {
                    getPositionAndOffset(it)
                }
            }
        })
        ivReset?.setOnClickListener(View.OnClickListener { v: View? -> resetFilter() })
        seekBarSaturability?.setOnSeekBarChangeListener(object : OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) {
                    setFilterLevel(sFilter.name, progress)
                }
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        seekToSeekBar(getFilterLevel(sFilter.name))
    }

    override fun onResume() {
        super.onResume()
        scrollToPosition()
    }

    /**
     * 记录RecyclerView当前位置
     */
    private fun getPositionAndOffset(layoutManager: RecyclerView.LayoutManager) {
        //获取可视的第一个view
        val leftView = layoutManager.getChildAt(0)
        if (leftView != null) {
            //获取与该view的顶部的偏移量
            lastOffset = leftView.top
            //得到该View的数组位置
            lastPosition = layoutManager.getPosition(leftView)
        }
    }

    /**
     * 让RecyclerView滚动到指定位置
     */
    private fun scrollToPosition() {
        if (rcvFilter?.layoutManager != null && lastPosition >= 0) {
            (rcvFilter?.layoutManager as LinearLayoutManager?)?.scrollToPositionWithOffset(
                lastPosition, lastOffset
            )
        }
    }

    /**
     * 设置滤镜leave 值
     *
     * @param filterName
     * @param faceBeautyFilterLevel
     */
    fun setFilterLevel(filterName: String?, faceBeautyFilterLevel: Int) {
        sFilterLevel?.set(filterName, faceBeautyFilterLevel)
        mOnFUControlListener?.onFilterLevelSelected(faceBeautyFilterLevel / 100f)

    }

    /**
     * 获取滤镜leave值
     *
     * @param filterName
     * @return
     */
    fun getFilterLevel(filterName: String?): Int {
        var level = sFilterLevel?.get(filterName)
        if (level == null) {
            level = DEFAULT_FILTER_LEVEL
            sFilterLevel?.set(filterName, level)
        }
        return level
    }

    private fun resetFilter() {
        sFilter = FilterEnum.origin.create()
        mFilterPositionSelect = 0
        filterRecyclerAdapter?.notifyDataSetChanged()

        mOnFUControlListener?.let {
            it.onFilterNameSelected(sFilter.name)
            setFilterLevel(sFilter.name, DEFAULT_FILTER_LEVEL)
            seekToSeekBar(DEFAULT_FILTER_LEVEL)
        }
        lastOffset = 0
        lastPosition = 0
        scrollToPosition()
    }

    /**
     * 设置seekBar值
     *
     * @param value
     */
    private fun seekToSeekBar(value: Int) {
        seekBarSaturability?.visibility = View.VISIBLE
        seekBarSaturability?.progress = value
    }

    internal inner class FilterRecyclerAdapter : RecyclerView.Adapter<HomeRecyclerHolder?>() {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): HomeRecyclerHolder {
            return HomeRecyclerHolder(
                LayoutInflater.from(context)
                    .inflate(R.layout.layout_beauty_control_recycler, parent, false)
            )
        }

        override fun onBindViewHolder(holder: HomeRecyclerHolder, position: Int) {
            val filters = mFilters
            filters?.get(position)?.iconId?.let {
                ImageLoader.with(context)
                    .circleLoad(it, holder.filterImg)
            }
            filters?.get(position)?.let { holder.filterName?.setText(it.nameId) }
            if (mFilterPositionSelect == position) {
                holder.focusStatus?.visibility = View.VISIBLE
                holder.filterName?.setTextColor(Color.parseColor("#337EFF"))
            } else {
                holder.focusStatus?.visibility = View.GONE
                holder.filterName?.setTextColor(Color.parseColor("#222222"))
            }
            holder.itemView.setOnClickListener { v: View? ->
                mFilterPositionSelect = position
                setFilterProgress()
                notifyDataSetChanged()
                mOnFUControlListener?.let {
                    sFilter = filters?.get(mFilterPositionSelect)
                    it.onFilterNameSelected(sFilter.name)
                    ToastUtils.showShort(sFilter.nameId)
                }
            }
        }

        override fun getItemCount(): Int {
            return mFilters.size
        }

        fun setFilterProgress() {
            if (mFilterPositionSelect > 0) {
                seekToSeekBar(getFilterLevel(mFilters.get(mFilterPositionSelect).name))
            }
        }

        internal inner class HomeRecyclerHolder(itemView: View) :
            RecyclerView.ViewHolder(itemView) {
            var filterImg: ImageView?
            var filterName: TextView?
            var focusStatus: View?

            init {
                filterImg = itemView.findViewById(R.id.iv_icon)
                filterName = itemView.findViewById(R.id.tv_filter_name)
                focusStatus = itemView.findViewById(R.id.focused_status)
            }
        }
    }

    companion object {
        /**
         * 每个滤镜强度值。key: name, value: level
         */
        var sFilterLevel: MutableMap<String?, Int?>? = HashMap()

        /**
         * 滤镜默认强度 0.4
         */
        const val DEFAULT_FILTER_LEVEL = 40

        /**
         * 默认滤镜 自然 2
         */
        var sFilter = FilterEnum.origin.create()

        // 默认选中第三个粉嫩
        private var mFilterPositionSelect = 0

        //恢复recyclerView 位置使用
        private var lastOffset = 0
        private var lastPosition = 0
    }
}