/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user.ui

import android.app.Dialog
import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import com.netease.yunxin.nertc.demo.user.UserCenterService
import com.netease.yunxin.nertc.demo.user.UserCenterServiceNotify
import com.netease.yunxin.nertc.demo.user.business.UserBizControl.logout
import com.netease.yunxin.nertc.user.R
import io.reactivex.observers.ResourceSingleObserver

/**
 * Created by luc on 2020/11/17.
 */
class LogoutDialog(context: Context, type: Int, notify: UserCenterServiceNotify?) :
    Dialog(context, R.style.LogoutDialog) {
    private fun initForType(rootView: View, type: Int) {
        if (type == UserCenterService.LOGOUT_DIALOG_TYPE_NORMAL) {
            initForNormal(rootView)
        } else if (type == UserCenterService.LOGOUT_DIALOG_TYPE_LOGIN_AGAIN) {
            initForLoginAgain(rootView)
        }
    }

    private fun initForLoginAgain(rootView: View) {
        val tvTitle = rootView.findViewById<TextView>(R.id.tv_logout_title)
        tvTitle.text = context.getString(R.string.biz_user_re_login)
        val tvContent = rootView.findViewById<TextView>(R.id.tv_logout_content)
        tvContent.text =
            context.getString(R.string.biz_user_current_user_has_logined_on_other_devices_please_re_login)
        val tvYes = rootView.findViewById<TextView>(R.id.tv_logout_yes)
        tvYes.text = context.getString(R.string.biz_user_i_know)
        rootView.findViewById<View>(R.id.line_divide).visibility =
            View.GONE
        rootView.findViewById<View>(R.id.tv_logout_no).visibility = View.GONE
        setCancelable(false)
    }

    private fun initForNormal(rootView: View) {
        val tvTitle = rootView.findViewById<TextView>(R.id.tv_logout_title)
        tvTitle.text = context.getString(R.string.biz_user_logout)
        val tvContent = rootView.findViewById<TextView>(R.id.tv_logout_content)
        tvContent.text = context.getString(R.string.biz_user_sure_logout_account)
        val tvYes = rootView.findViewById<TextView>(R.id.tv_logout_yes)
        tvYes.text = context.getString(R.string.biz_user_yes)
        rootView.findViewById<View>(R.id.line_divide).visibility = View.VISIBLE
        rootView.findViewById<View>(R.id.tv_logout_no).visibility =
            View.VISIBLE
        setCancelable(true)
    }

    init {
        val rootView = LayoutInflater.from(getContext()).inflate(R.layout.view_logout_dialog, null)
        val tvNo = rootView.findViewById<View>(R.id.tv_logout_no)
        tvNo.setOnClickListener { dismiss() }
        initForType(rootView, type)
        val tvYes = rootView.findViewById<View>(R.id.tv_logout_yes)
        tvYes.setOnClickListener {
            dismiss()
            logout().subscribe(object : ResourceSingleObserver<Boolean?>() {
                override fun onSuccess(aBoolean: Boolean) {
                    LoginActivity.startLogin(context)
                    notify?.onUserLogout(aBoolean, 0)
                }

                override fun onError(e: Throwable) {
                    notify?.onError(e)
                }
            })
        }
        setContentView(rootView)
    }
}