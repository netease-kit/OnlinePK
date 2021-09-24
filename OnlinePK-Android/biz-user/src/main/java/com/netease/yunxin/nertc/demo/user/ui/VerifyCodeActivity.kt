/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user.ui

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.CountDownTimer
import android.text.TextUtils
import android.view.View
import android.widget.Button
import android.widget.TextView
import com.blankj.utilcode.util.ToastUtils
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.uinfo.UserService
import com.netease.nimlib.sdk.uinfo.constant.UserInfoFieldEnum
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import com.netease.yunxin.nertc.demo.user.UserCenterService
import com.netease.yunxin.nertc.demo.user.business.UserBizControl.login
import com.netease.yunxin.nertc.demo.user.network.UserServerImpl
import com.netease.yunxin.nertc.demo.user.ui.view.VerifyCodeView
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr
import com.netease.yunxin.nertc.user.R
import io.reactivex.observers.ResourceSingleObserver
import java.util.*

class VerifyCodeActivity : BaseActivity() {
    private var verifyCodeView //验证码输入框
            : VerifyCodeView? = null
    private var tvMsmComment: TextView? = null
    private var btnNext: Button? = null
    private var tvTimeCountDown: TextView? = null
    private var phoneNumber: String? = null
    private var countDownTimer: CountDownTimer? = null
    private var tvResendMsm: TextView? = null
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
        setContentView(R.layout.verify_code_layout)
        initView()
        initData()
    }

    private fun initView() {
        verifyCodeView = findViewById(R.id.vcv_sms)
        tvMsmComment = findViewById(R.id.tv_msm_comment)
        btnNext = findViewById(R.id.btn_next)
        tvTimeCountDown = findViewById(R.id.tv_time_discount)
        tvResendMsm = findViewById(R.id.tv_resend_msm)
    }

    private fun initData() {
        phoneNumber = intent.getStringExtra(PHONE_NUMBER)
        tvMsmComment!!.text =
            getString(R.string.biz_user_auth_code_has_sent_to) + getString(R.string.biz_user_phonenumber_prefix) + phoneNumber + getString(
                R.string.biz_user__please_input_auth_code_below
            )
        btnNext!!.setOnClickListener {
            val smsCode = verifyCodeView?.result
            if (!TextUtils.isEmpty(smsCode)) {
                login(smsCode!!)
            }
        }
        tvTimeCountDown!!.setOnClickListener { v: View? -> reSendMsm() }
        initCountDown()
    }

    private fun initCountDown() {
        tvTimeCountDown!!.text = "60s"
        tvResendMsm!!.visibility = View.VISIBLE
        tvTimeCountDown!!.isEnabled = false
        countDownTimer = object : CountDownTimer(60000, 1000) {
            override fun onTick(l: Long) {
                tvTimeCountDown!!.text = (l / 1000).toString() + "s"
            }

            override fun onFinish() {
                tvTimeCountDown!!.text = getString(R.string.biz_user_resend)
                tvTimeCountDown!!.isEnabled = true
                tvResendMsm!!.visibility = View.GONE
            }
        }
        countDownTimer?.start()
    }

    private fun reSendMsm() {
        if (!TextUtils.isEmpty(phoneNumber)) {
            UserServerImpl.sendVerifyCode(phoneNumber)
                .subscribe(object : ResourceSingleObserver<Boolean?>() {
                    override fun onSuccess(aBoolean: Boolean) {
                        if (aBoolean) {
                            ToastUtils.showLong(getString(R.string.biz_user_re_send_success))
                            initCountDown()
                        } else {
                            ToastUtils.showLong(getString(R.string.biz_user_re_send_failed))
                        }
                    }

                    override fun onError(e: Throwable) {
                        ToastUtils.showLong(getString(R.string.biz_user_re_send_failed))
                    }
                })
        }
    }

    private fun login(msmCode: String) {
        if (!TextUtils.isEmpty(phoneNumber) && !TextUtils.isEmpty(msmCode)) {
            login(phoneNumber!!, msmCode).subscribe(object : ResourceSingleObserver<Boolean?>() {
                override fun onSuccess(aBoolean: Boolean) {
                    if (aBoolean) {
                        ToastUtils.showLong(getString(R.string.biz_user_login_success))
                        val userCenterService =
                            ModuleServiceMgr.instance.getService(UserCenterService::class.java)
                        val service: UserService = NIMClient.getService(UserService::class.java)
                        val map = HashMap<UserInfoFieldEnum, Any>()
                        map[UserInfoFieldEnum.Name] =
                            userCenterService.currentUser.getNickname().toString()
                        map[UserInfoFieldEnum.AVATAR] =
                            userCenterService.currentUser.avatar.toString()
                        service.updateUserInfo(map)
                        startMainActivity()
                    } else {
                        ToastUtils.showLong(getString(R.string.biz_user_login_failed))
                    }
                }

                override fun onError(e: Throwable) {
                    ToastUtils.showLong(getString(R.string.biz_user_login_failed))
                }
            })
        }
    }

    private fun startMainActivity() {
        val intent = Intent()
        intent.addCategory("android.intent.category.DEFAULT")
        intent.action = "com.nertc.interaction.action.main"
        startActivity(intent)
        finish()
    }

    companion object {
        const val PHONE_NUMBER = "phone_number"
        fun startVerifyCode(context: Context, phoneNumber: String?) {
            val intent = Intent()
            intent.setClass(context, VerifyCodeActivity::class.java)
            intent.putExtra(PHONE_NUMBER, phoneNumber)
            context.startActivity(intent)
        }
    }
}