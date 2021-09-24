/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.dialog.adapter

import android.app.Activity
import android.view.*
import android.widget.*
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.*
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.dialog.ChoiceDialog
import com.netease.biz_live.yunxin.live.utils.ClickUtils
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.seatlibrary.CompletionCallback
import com.netease.yunxin.seatlibrary.seat.constant.AudienceType
import com.netease.yunxin.seatlibrary.seat.constant.SeatAVState
import com.netease.yunxin.seatlibrary.seat.model.SeatInfo
import com.netease.yunxin.seatlibrary.seat.params.AnchorActionSeatParams
import com.netease.yunxin.seatlibrary.seat.params.SetSeatAVMuteStateParams
import com.netease.yunxin.seatlibrary.seat.service.SeatService
import java.util.*

/**
 * 观众列表
 */
class AudienceListAdapter(context: Activity?, type: Int) :
    RecyclerView.Adapter<RecyclerView.ViewHolder?>() {
    private val memberInfos: ArrayList<SeatInfo> = ArrayList()
    private val type: Int = type
    private val context: Activity? = context
    private val seatService by lazy { SeatService.sharedInstance() }

    fun setData(members: MutableList<SeatInfo>?) {
        if (members == null) {
            return
        }
        memberInfos.clear()
        memberInfos.addAll(members)
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            AudienceType.AUDIENCE_TYPE_APPLY -> {
                val apply = LayoutInflater.from(parent.context)
                    .inflate(R.layout.view_item_audience_apply, parent, false)
                ApplyAudienceViewHolder(apply)
            }
            AudienceType.AUDIENCE_TYPE_ON_SEAT -> {
                val seat = LayoutInflater.from(parent.context)
                    .inflate(R.layout.view_item_audience_seats, parent, false)
                SeatAudienceViewHolder(seat)
            }
            else -> {
                val common = LayoutInflater.from(parent.context)
                    .inflate(R.layout.view_item_audience_common, parent, false)
                AudienceCommonViewHolder(common)
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (context == null) {
            return
        }
        if (holder is AudienceViewHolder) {
            val member = memberInfos.get(position)
            holder.mTvNumber.text = (position + 1).toString()
            holder.mTvNick.text = member.nickName
            ImageLoader.with(context)
                .circleLoad(member.avatar, holder.mIvAvatar)
            val params = AnchorActionSeatParams(null, member.accountId)
            when (holder) {
                is AudienceCommonViewHolder -> {
                    holder.mTvInvite.setOnClickListener(View.OnClickListener {
                        if (ClickUtils.isFastClick()) {
                            return@OnClickListener
                        }
                        seatService.pickSeat(params, object : CompletionCallback<String> {
                            override fun success(info: String?) {
                                removeMember(member)
                                ToastUtils.showShort(R.string.biz_live_anchor_invite_success)
                            }

                            override fun error(code: Int, msg: String) {
                                ToastUtils.showShort(msg)
                            }


                        })
                    })
                }
                is ApplyAudienceViewHolder -> {
                    holder.mTvAccept.setOnClickListener(View.OnClickListener {
                        if (ClickUtils.isFastClick()) {
                            return@OnClickListener
                        }
                        seatService.acceptSeatApply(
                            params,
                            object : CompletionCallback<Void> {
                                override fun success(info: Void?) {
                                    removeMember(member)
                                    ToastUtils.showShort(R.string.biz_live_have_accepted)
                                }

                                override fun error(code: Int, msg: String) {
                                    ToastUtils.showShort(msg)
                                }
                            })
                    })
                    holder.mTvReject.setOnClickListener(View.OnClickListener { v: View? ->
                        if (ClickUtils.isFastClick()) {
                            return@OnClickListener
                        }
                        seatService.rejectSeatApply(
                            params,
                            object : CompletionCallback<Void> {
                                override fun success(info: Void?) {
                                    removeMember(member)
                                    ToastUtils.showShort(R.string.biz_live_have_reject)
                                }

                                override fun error(code: Int, msg: String) {
                                    ToastUtils.showShort(msg)
                                }
                            })
                    })
                }
                is SeatAudienceViewHolder -> {
                    holder.mIvAudio.isSelected = member.audioState == 0
                    holder.mIvVideo.isSelected = member.videoState == 0
                    holder.mIvAudio.setOnClickListener(View.OnClickListener { v: View ->
                        if (ClickUtils.isFastClick()) {
                            return@OnClickListener
                        }
                        val audioParams = SetSeatAVMuteStateParams(
                            null,
                            member.accountId,
                            if (v.isSelected) SeatAVState.OPEN else SeatAVState.CLOSE
                        )
                        seatService.setSeatAudioMuteState(
                            audioParams,
                            object : CompletionCallback<Void> {
                                override fun success(info: Void?) {
                                    v.isSelected = !v.isSelected
                                    member.audioState = if (v.isSelected) 0 else 1
                                }

                                override fun error(code: Int, msg: String) {
                                    ToastUtils.showShort(msg)
                                }
                            })
                    })
                    holder.mIvVideo.setOnClickListener(View.OnClickListener { v: View ->
                        if (ClickUtils.isFastClick()) {
                            return@OnClickListener
                        }
                        val videoParams = SetSeatAVMuteStateParams(
                            null,
                            member.accountId,
                            if (v.isSelected) SeatAVState.OPEN else SeatAVState.CLOSE
                        )
                        seatService.setSeatVideoMuteState(
                            videoParams,
                            object : CompletionCallback<Void> {
                                override fun success(info: Void?) {
                                    v.isSelected = !v.isSelected
                                    member.videoState = if (v.isSelected) 0 else 1
                                }

                                override fun error(code: Int, msg: String) {
                                    ToastUtils.showShort(msg)
                                }
                            })
                    })
                    holder.mTvHangup.setOnClickListener(View.OnClickListener { v: View ->
                        if (ClickUtils.isFastClick()) {
                            return@OnClickListener
                        }
                        showKickDialog(member)
                    })
                }
            }
        }
    }

    private fun removeMember(member: SeatInfo?) {
        val index = memberInfos.indexOf(member)
        if (index >= 0) {
            memberInfos.removeAt(index)
            notifyItemRemoved(index)
        }
    }

    /**
     * 踢下麦二次确认
     *
     * @param member
     */
    private fun showKickDialog(member: SeatInfo?) {
        if (context == null) {
            return
        }
        val dialog = ChoiceDialog(context)
        dialog.setContent(
            String.format(
                Utils.getApp().getString(R.string.biz_live_sure_hanup_link_seat),
                member?.nickName
            )
        )
            .setNegative(Utils.getApp().getString(R.string.biz_live_cancel)) { }
            .setPositive(Utils.getApp().getString(R.string.biz_live_hangup)) {
                val params = AnchorActionSeatParams(null, member?.accountId)
                seatService.kickSeat(params, object : CompletionCallback<Void> {
                    override fun success(info: Void?) {
                        removeMember(member)
                        ToastUtils.showShort(R.string.biz_live_have_kick_seat)
                    }

                    override fun error(code: Int, msg: String) {
                        ToastUtils.showShort(msg)
                    }
                })
            }.show()
    }

    override fun getItemViewType(position: Int): Int {
        return type
    }

    override fun getItemCount(): Int {
        return memberInfos.size
    }

    private open class AudienceViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var mTvNumber: TextView = itemView.findViewById(R.id.tv_audience_no)
        var mIvAvatar: ImageView = itemView.findViewById(R.id.iv_audience_avatar)
        var mTvNick: TextView = itemView.findViewById(R.id.tv_audience_nickname)

    }

    private class AudienceCommonViewHolder(itemView: View) : AudienceViewHolder(itemView) {
        var mTvInvite: TextView = itemView.findViewById(R.id.tv_invite)

    }

    private class ApplyAudienceViewHolder(itemView: View) : AudienceViewHolder(itemView) {
        var mTvReject: TextView = itemView.findViewById(R.id.tv_reject)
        var mTvAccept: TextView = itemView.findViewById(R.id.tv_accept)

    }

    private class SeatAudienceViewHolder(itemView: View) : AudienceViewHolder(itemView) {
        var mIvVideo: ImageView = itemView.findViewById(R.id.iv_video)
        var mIvAudio: ImageView = itemView.findViewById(R.id.iv_audio)
        var mTvHangup: TextView = itemView.findViewById(R.id.tv_hangup)

    }

}