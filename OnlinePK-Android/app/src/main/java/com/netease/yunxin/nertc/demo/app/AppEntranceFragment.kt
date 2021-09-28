/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.app

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.netease.biz_live.yunxin.live.LiveService
import com.netease.yunxin.nertc.demo.R
import com.netease.yunxin.nertc.demo.basic.BaseFragment
import com.netease.yunxin.nertc.demo.list.FunctionAdapter
import com.netease.yunxin.nertc.demo.list.FunctionItem
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr
import java.util.*

class AppEntranceFragment : BaseFragment() {
    companion object {
        const val LIVE_TYPE_PK = 2
        const val LIVE_TYPE_SEAT = 3
    }

    private fun initView(rootView: View) {
        // 功能列表初始化
        val rvFunctionList: RecyclerView = rootView.findViewById(R.id.rv_function_list)
        rvFunctionList.layoutManager =
            LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
        rvFunctionList.adapter = FunctionAdapter(
            context, Arrays.asList( // 每个业务功能入口均在此处生成 item
                FunctionItem(
                    R.drawable.icon_pk_live,
                    getString(R.string.app_pk_live),
                    getString(R.string.app_pk_live_desc_text)
                ) {
                    val liveService: LiveService =
                        ModuleServiceMgr.instance.getService(LiveService::class.java)
                    liveService.launchPkLive(
                        requireContext(),
                        getString(R.string.app_pk_live2),
                        LIVE_TYPE_PK
                    )
                },
                FunctionItem(
                    R.drawable.icon_multi_micro,
                    getString(R.string.app_multiple_link_seat_live),
                    getString(R.string.app_multiple_link_seat_live_desc_text)
                ) {
                    val liveService: LiveService =
                        ModuleServiceMgr.instance.getService(LiveService::class.java)
                    liveService.launchPkLive(
                        requireContext(),
                        getString(R.string.app_multiple_link_seat_live),
                        LIVE_TYPE_SEAT
                    )
                }
            )
        )
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val rootView = inflater.inflate(R.layout.fragment_app_entrance, container, false)
        initView(rootView)
        paddingStatusBarHeight(rootView)
        return rootView
    }
}