/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.dialog.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.anchor.dialog.adapter.AudienceListAdapter
import com.netease.yunxin.seatlibrary.CompletionCallback
import com.netease.yunxin.seatlibrary.seat.net.AudienceResp
import com.netease.yunxin.seatlibrary.seat.service.SeatService

class AudienceListFragment : Fragment() {
    private var type = 0
    private var roomId: String? = null
    private var audienceListAdapter: AudienceListAdapter? = null
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val rootView = inflater.inflate(R.layout.fragment_audience_list_layout, container, false)
        initView(rootView)
        return rootView
    }

    private fun initView(view: View?) {
        arguments?.let{
            val bundle = it
            type = bundle.getInt(TYPE)
            roomId = bundle.getString(ROOM_ID)
        }
        val rvAudienceList: RecyclerView? = view?.findViewById(R.id.rcv_audience)
        rvAudienceList?.layoutManager = LinearLayoutManager(context)
        audienceListAdapter = AudienceListAdapter(activity, type)
        rvAudienceList?.adapter = audienceListAdapter
    }

    override fun onResume() {
        super.onResume()
        SeatService.sharedInstance()
            .getAudienceList(type, PAGE_SIZE, callback = object : CompletionCallback<AudienceResp> {
                override fun success(info: AudienceResp?) {
                    audienceListAdapter?.setData(info?.seatList?.toMutableList())
                }

                override fun error(code: Int, msg: String) {
                    ToastUtils.showLong(msg)
                }

            })
    }

    companion object {
        const val ROOM_ID: String = "room_id"
        const val TYPE: String = "audience_type"
        const val PAGE_SIZE = 50
    }
}