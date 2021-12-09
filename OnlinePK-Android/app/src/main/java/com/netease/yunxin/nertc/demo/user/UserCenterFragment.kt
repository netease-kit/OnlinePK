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
import com.netease.yunxin.login.sdk.AuthorManager
import com.netease.yunxin.login.sdk.model.EventType
import com.netease.yunxin.login.sdk.model.LoginEvent
import com.netease.yunxin.login.sdk.model.LoginObserver
import com.netease.yunxin.login.sdk.model.UserInfo
import com.netease.yunxin.nertc.demo.R
import com.netease.yunxin.nertc.demo.basic.BaseFragment
import com.netease.yunxin.nertc.demo.basic.CommonBrowseActivity
import com.netease.yunxin.nertc.demo.basic.Constants

class UserCenterFragment : BaseFragment() {

    private val loginObserver:LoginObserver<LoginEvent> = object :LoginObserver<LoginEvent>{
        override fun onEvent(event: LoginEvent) {
            if (event.eventType == EventType.TYPE_UPDATE){
                currentUserInfo = event.userInfo
                initUser(rootView)
            }
        }
    }
    private var currentUserInfo: UserInfo?
    private var rootView: View? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AuthorManager.registerLoginObserver(loginObserver)
    }

    override fun onDestroy() {
        super.onDestroy()
        AuthorManager.unregisterLoginObserver(loginObserver)
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
        if (currentUserInfo == null) {
            if (activity != null) {
                requireActivity().finish()
            }
            return
        }
        val ivUserPortrait = rootView!!.findViewById<ImageView>(R.id.iv_user_portrait)
        ImageLoader.with(context).circleLoad(currentUserInfo!!.avatar, ivUserPortrait)
        val tvUserName = rootView.findViewById<TextView>(R.id.tv_user_name)
        tvUserName.text = currentUserInfo!!.nickname
    }

    init {
        currentUserInfo = AuthorManager.getUserInfo()
    }
}