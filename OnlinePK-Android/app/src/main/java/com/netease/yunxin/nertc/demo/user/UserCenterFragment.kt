/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.nertc.demo.R
import com.netease.yunxin.nertc.demo.basic.BaseFragment
import com.netease.yunxin.nertc.demo.basic.CommonBrowseActivity
import com.netease.yunxin.nertc.demo.basic.Constants
import com.netease.yunxin.nertc.demo.user.UserCenterService
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr

class UserCenterFragment : BaseFragment() {
    private val service: UserCenterService = ModuleServiceMgr.instance.getService(
        UserCenterService::class.java
    )
    private val notify: UserCenterServiceNotify = object : CommonUserNotify() {
        override fun onUserInfoUpdate(model: UserModel?) {
            currentUser = model
            initUser(rootView)
        }
    }
    private var currentUser: UserModel?
    private var rootView: View? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        service.registerLoginObserver(notify, true)
    }

    override fun onDestroy() {
        super.onDestroy()
        service.registerLoginObserver(notify, false)
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        rootView = inflater.inflate(R.layout.fragment_user_center, container, false)
        initViews(rootView)
        paddingStatusBarHeight(rootView)
        return rootView
    }

    private fun initViews(rootView: View?) {
        initUser(rootView)
        val userInfoGroup = rootView!!.findViewById<View>(R.id.rl_user_group)
        userInfoGroup.setOnClickListener { v: View? ->
            startActivity(
                Intent(
                    context,
                    UserInfoActivity::class.java
                )
            )
        }
        val aboutApp = rootView.findViewById<View>(R.id.tv_app_about)
        aboutApp.setOnClickListener { v: View? ->
            startActivity(
                Intent(
                    context,
                    AppAboutActivity::class.java
                )
            )
        }
        val freeTrail = rootView.findViewById<View>(R.id.tv_free_trail)
        freeTrail.setOnClickListener { v: View? ->
            CommonBrowseActivity.launch(
                requireActivity(), getString(R.string.app_free_trial), Constants.URL_FREE_TRAIL
            )
        }
    }

    private fun initUser(rootView: View?) {
        if (currentUser == null) {
            if (activity != null) {
                activity!!.finish()
            }
            return
        }
        val ivUserPortrait = rootView!!.findViewById<ImageView>(R.id.iv_user_portrait)
        ImageLoader.with(context).circleLoad(currentUser!!.avatar, ivUserPortrait)
        val tvUserName = rootView.findViewById<TextView>(R.id.tv_user_name)
        tvUserName.text = currentUser!!.nickname
    }

    init {
        currentUser = service.currentUser
    }
}