/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.pager

import android.util.SparseArray
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.netease.yunxin.nertc.demo.app.AppEntranceFragment
import com.netease.yunxin.nertc.demo.user.UserCenterFragment

class MainPagerAdapter(fm: FragmentManager) :
    FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {
    override fun getItem(position: Int): Fragment {
        return getFragmentByPosition(position)
    }

    override fun getCount(): Int {
        return 2
    }

    /**
     * fragment 缓存
     */
    private val fragmentCache = SparseArray<Fragment>(2)

    /**
     * 获取对应位置 fragment
     *
     * @param position 位置
     * @return fragment
     */
    private fun getFragmentByPosition(position: Int): Fragment {
        var fragment = fragmentCache[position]
        if (fragment != null) {
            return fragment
        }
        if (position == 0) {
            fragment = AppEntranceFragment()
        } else if (position == 1) {
            fragment = UserCenterFragment()
        }
        fragmentCache.put(position, fragment)
        return fragment
    }
}