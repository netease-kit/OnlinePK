/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.dialog.adapter

import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.netease.biz_live.yunxin.live.anchor.dialog.fragment.AudienceListFragment
import com.netease.yunxin.seatlibrary.seat.constant.AudienceType
import java.util.*

class AudiencePageAdapter(fm: FragmentManager, roomId: String) :
    FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {
    private val roomId: String?
    override fun getItem(position: Int): Fragment {
        val bundle = Bundle()
        bundle.putString(AudienceListFragment.Companion.ROOM_ID, roomId)
        when (position) {
            0 -> bundle.putInt(
                AudienceListFragment.TYPE,
                AudienceType.AUDIENCE_TYPE_IDLE
            )
            1 -> bundle.putInt(
                AudienceListFragment.TYPE,
                AudienceType.AUDIENCE_TYPE_APPLY
            )
            2 -> bundle.putInt(
                AudienceListFragment.TYPE,
                AudienceType.AUDIENCE_TYPE_ON_SEAT
            )
        }
        cacheFragment[position].arguments = bundle
        return cacheFragment[position]
    }

    override fun getCount(): Int {
        return SIZE
    }

    private val cacheFragment: MutableList<AudienceListFragment> = ArrayList(SIZE)
    private fun initFragment() {
        for (i in 0 until SIZE) {
            cacheFragment.add(AudienceListFragment())
        }
    }

    companion object {
        private const val SIZE = 3
    }

    init {
        this.roomId = roomId
        initFragment()
    }
}