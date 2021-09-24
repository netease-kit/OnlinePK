/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user.ui

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.TextPaint
import android.text.TextUtils
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import com.blankj.utilcode.util.ToastUtils
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.CommonBrowseActivity
import com.netease.yunxin.nertc.demo.basic.Constants
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import com.netease.yunxin.nertc.demo.user.network.UserServerImpl
import com.netease.yunxin.nertc.user.R
import io.reactivex.observers.ResourceSingleObserver

class LoginActivity : BaseActivity() {
    private var mEdtPhoneNumber: EditText? = null
    private var mBtnSendMessage: Button? = null
    override fun provideStatusBarConfig(): StatusBarConfig {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(true)
            .statusBarColor(R.color.colorWhite)
            .fitsSystemWindow(true)
            .build()
    }

    override fun ignoredLoginEvent(): Boolean {
        return true
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.login_activity)
        initView()
    }

    private fun initView() {
        mEdtPhoneNumber = findViewById(R.id.edt_phone_number)
        mBtnSendMessage = findViewById(R.id.btn_send)
        mBtnSendMessage?.setOnClickListener { sendMsm() }
        val tvPolice = findViewById<TextView>(R.id.tv_login_police)
        initPolice(tvPolice)
    }

    private fun initPolice(tvPolice: TextView) {
        val builder =
            SpannableStringBuilder(getString(R.string.biz_user_login_as_you_have_agree_to))
        var start = builder.length
        builder.append(getString(R.string.biz_user_privacy_policy))
        builder.setSpan(object : ClickableSpan() {
            override fun updateDrawState(ds: TextPaint) {
                super.updateDrawState(ds)
                ds.color = Color.parseColor("#ff337eef")
                ds.isUnderlineText = false
            }

            override fun onClick(widget: View) {
                CommonBrowseActivity.launch(
                    this@LoginActivity,
                    getString(R.string.biz_user_privacy_policy),
                    Constants.URL_PRIVACY
                )
            }
        }, start, builder.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        builder.append(getString(R.string.user_biz_and))
        start = builder.length
        builder.append(getString(R.string.biz_user_user_service_agreement))
        builder.setSpan(object : ClickableSpan() {
            override fun updateDrawState(ds: TextPaint) {
                super.updateDrawState(ds)
                ds.color = Color.parseColor("#ff337eef")
                ds.isUnderlineText = false
            }

            override fun onClick(widget: View) {
                CommonBrowseActivity.launch(
                    this@LoginActivity,
                    getString(R.string.biz_user_user_agreement),
                    Constants.URL_USER_POLICE
                )
            }
        }, start, builder.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        tvPolice.movementMethod = LinkMovementMethod.getInstance()
        tvPolice.text = builder
    }

    private fun sendMsm() {
        val phoneNumber = mEdtPhoneNumber!!.text.toString().trim { it <= ' ' }
        if (!TextUtils.isEmpty(phoneNumber)) {
            UserServerImpl.sendVerifyCode(phoneNumber)
                .subscribe(object : ResourceSingleObserver<Boolean?>() {
                    override fun onSuccess(aBoolean: Boolean) {
                        if (!aBoolean) {
                            ToastUtils.showShort(getString(R.string.biz_user_send_auth_code_failed))
                            return
                        }
                        VerifyCodeActivity.Companion.startVerifyCode(
                            this@LoginActivity,
                            phoneNumber
                        )
                        finish()
                    }

                    override fun onError(e: Throwable) {
                        ToastUtils.showShort(getString(R.string.biz_user_send_auth_code_failed))
                        e.printStackTrace()
                    }
                })
        }
    }

    companion object {
        fun startLogin(context: Context) {
            val intent = Intent()
            intent.setClass(context, LoginActivity::class.java)
            if (context !is Activity) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        }
    }
}