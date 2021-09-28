/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui.widget

import android.content.Context
import android.graphics.Rect
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.ConvertUtils
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo
import com.netease.biz_live.yunxin.live.ui.widget.LinkSeatsAudienceRecycleView.SeatsViewHolder.CloseCallback
import com.netease.biz_live.yunxin.live.ui.widget.SingleAudienceSeatsView.CloseSeatCallback
import com.netease.yunxin.seatlibrary.Attachment
import com.netease.yunxin.seatlibrary.CompletionCallback
import com.netease.yunxin.seatlibrary.seat.params.AnchorActionSeatParams
import com.netease.yunxin.seatlibrary.seat.service.SeatService
import java.util.*

/**
 * @author sunkeding
 * 连麦观众列表,主播端、观众端使用交互略有不同
 */
class LinkSeatsAudienceRecycleView : RecyclerView {
    private val list: ArrayList<SeatMemberInfo> = ArrayList()
    private val mAdapter by lazy {
        SeatsAdapter(context, list)
    }

    constructor(context: Context) : super(context) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        init(context)
    }

    private fun init(context: Context?) {
        itemAnimator = null
        layoutManager = LinearLayoutManager(context)
        addItemDecoration(object : ItemDecoration() {
            override fun getItemOffsets(
                outRect: Rect,
                view: View,
                parent: RecyclerView,
                state: State
            ) {
                super.getItemOffsets(outRect, view, parent, state)
                val position = parent.getChildAdapterPosition(view)
                if (position == 0) {
                    outRect.top = 0
                } else {
                    outRect.top = dp8
                }
            }
        })
        adapter = mAdapter
    }

    fun setUseScene(useScene: Int) {
        mAdapter.setUseScene(useScene)
    }

    fun appendItem(member: SeatMemberInfo?) {
        mAdapter.appendItem(member)
    }

    fun clearItems() {
        mAdapter.clearItem()
    }

    fun appendItem(targetIndex: Int, member: SeatMemberInfo?) {
        mAdapter.appendItem(targetIndex, member)
    }

    fun appendItems(appendList: MutableList<SeatMemberInfo>?) {
        mAdapter.appendItems(appendList)
    }

    fun remove(index: Int) {
        mAdapter.remove(index)
    }

    fun remove(member: SeatMemberInfo?) {
        mAdapter.remove(member)
    }

    fun haveMemberInSeats(): Boolean {
        return !list.isEmpty()
    }

    operator fun contains(accountId: String?): Boolean {
        for (member in list) {
            if (!TextUtils.isEmpty(accountId) && accountId == member.seatInfo.accountId) {
                return true
            }
        }
        return false
    }

    /**
     * 获取麦上观众
     *
     * @return
     */
    fun getMemberList(): MutableList<SeatMemberInfo> {
        return list
    }

    fun updateItem(index: Int, member: SeatMemberInfo) {
        mAdapter.updateItem(index, member)
    }

    fun updateItem(member: SeatMemberInfo) {
        mAdapter.updateItem(member)
    }

    class SeatsAdapter(
        private val context: Context?,
        private val list: ArrayList<SeatMemberInfo>
    ) : Adapter<ViewHolder?>() {
        /**
         * 使用场景，分为主播端，观众端
         */
        private var useScene = UseScene.UNKNOWN

        fun setUseScene(useScene: Int) {
            this.useScene = useScene
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            return SeatsViewHolder(
                LayoutInflater.from(context)
                    .inflate(R.layout.biz_live_single_seats_layout, parent, false)
            )
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            val member = list[position]
            val seatsViewHolder = holder as SeatsViewHolder
            seatsViewHolder.bindData(member, useScene)
            seatsViewHolder.setCloseCallback(object : CloseCallback {
                override fun closeSeat(member: SeatMemberInfo?) {
                    if (UseScene.UNKNOWN == useScene) {
                        return
                    }
                    if (UseScene.ANCHOR == useScene) {
                        val params =
                            AnchorActionSeatParams(toAccountId = member?.seatInfo?.accountId)
                        SeatService.sharedInstance()
                            .kickSeat(params, object : CompletionCallback<Void> {
                                override fun success(info: Void?) {
                                    remove(member)
                                }

                                override fun error(code: Int, msg: String) {
                                    ToastUtils.showShort(msg)
                                }

                            })
                    } else if (UseScene.AUDIENCE == useScene) {
                        SeatService.sharedInstance()
                            .leaveSeat(Attachment(), object : CompletionCallback<Void> {
                                override fun success(info: Void?) {
                                    remove(member)
                                }

                                override fun error(code: Int, msg: String) {
                                    ToastUtils.showShort(msg)
                                }

                            })
                    }
                }
            })
        }

        override fun getItemCount(): Int {
            return list.size
        }

        fun appendItem(member: SeatMemberInfo?) {
            if (member == null) {
                return
            }
            if (list.contains(member)) {
                return
            }
            list.add(member)
            notifyItemInserted(list.size - 1)
        }

        fun clearItem() {
            list.clear()
            notifyDataSetChanged()
        }

        fun appendItem(targetIndex: Int, member: SeatMemberInfo?) {
            if (member == null || targetIndex < 0) {
                return
            }
            if (list.contains(member)) {
                return
            }
            list.add(targetIndex, member)
            notifyItemRangeInserted(targetIndex, list.size - targetIndex)
        }

        fun appendItems(appendList: MutableList<SeatMemberInfo>?) {
            if (appendList == null || appendList.isEmpty()) {
                return
            }
            val positionStart = list.size
            var appendCount = 0
            for (member in appendList) {
                if (!list.contains(member)) {
                    list.add(member)
                    appendCount++
                }
            }
            if (appendCount > 0) {
                notifyItemRangeInserted(positionStart, appendCount)
            }
        }

        fun remove(index: Int) {
            list.removeAt(index)
            notifyItemRemoved(index)
        }

        fun remove(member: SeatMemberInfo?) {
            if (member == null) {
                return
            }
            val removeIndex = list.indexOf(member)
            if (removeIndex >= 0) {
                list.removeAt(removeIndex)
                notifyItemRemoved(removeIndex)
            }
        }

        fun updateItem(index: Int, member: SeatMemberInfo) {
            list.set(index, member)
            notifyItemChanged(index)
        }

        fun updateItem(member: SeatMemberInfo) {
            val targetIndex = list.indexOf(member)
            if (targetIndex >= 0) {
                updateItem(targetIndex, member)
            }
        }
    }

    private class SeatsViewHolder(itemView: View) : ViewHolder(itemView) {
        private val seatsView: SingleAudienceSeatsView? = itemView.findViewById(R.id.audience_seats_view)
        private var closeCallback: CloseCallback? = null
        fun bindData(member: SeatMemberInfo?, useScene: Int) {
            seatsView?.initLiveRoom(UseScene.ANCHOR == useScene)
            seatsView?.setData(member)
            seatsView?.setCloseSeatCallback(object : CloseSeatCallback {
                override fun closeSeat(member: SeatMemberInfo?) {
                    closeCallback?.closeSeat(
                        member
                    )
                }
            })
        }

        fun setCloseCallback(closeCallback: CloseCallback?) {
            this.closeCallback = closeCallback
        }

        interface CloseCallback {
            open fun closeSeat(member: SeatMemberInfo?)
        }

    }

    interface UseScene {
        companion object {
            const val UNKNOWN = -1
            const val ANCHOR = 0
            const val AUDIENCE = 1
        }
    }

    companion object {
        private val dp8 = ConvertUtils.dp2px(8f)
    }
}