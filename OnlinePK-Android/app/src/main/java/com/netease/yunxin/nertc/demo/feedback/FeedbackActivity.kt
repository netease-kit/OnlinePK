/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.feedback

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.View
import android.widget.EditText
import android.widget.TextView
import com.blankj.utilcode.util.ToastUtils
import com.netease.yunxin.login.sdk.AuthorManager
import com.netease.yunxin.nertc.demo.R
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import com.netease.yunxin.nertc.demo.feedback.expand.QuestionItem
import com.netease.yunxin.nertc.demo.feedback.network.FeedbackServiceImpl
import io.reactivex.observers.ResourceSingleObserver
import java.util.*

class FeedbackActivity : BaseActivity() {

    private val userModel = AuthorManager.getUserInfo()
    private val questionTypeList = ArrayList<QuestionItem>()
    private var tvDemoName: TextView? = null
    private var tvQuestionType: TextView? = null
    private var etQuestionDesc: EditText? = null
    private var btnCommit: View? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_feed_back)
        paddingStatusBarHeight(findViewById(R.id.cl_root))
        initViews()
    }

    private fun initViews() {
        val close = findViewById<View>(R.id.iv_close)
        close.setOnClickListener { v: View? -> finish() }
        tvQuestionType = findViewById(R.id.tv_question_type)
        tvQuestionType?.setOnClickListener(View.OnClickListener { v: View? ->
            QuestionTypeActivity.Companion.launchForResult(
                this@FeedbackActivity,
                CODE_REQUEST_FOR_QUESTION,
                questionTypeList
            )
        })
        tvDemoName = findViewById(R.id.tv_demo_name)
        tvDemoName?.setOnClickListener(View.OnClickListener { v: View? ->
            DemoNameActivity.launchForResult(
                this@FeedbackActivity,
                CODE_REQUEST_FOR_NAME,
                tvDemoName?.text.toString()
            )
        })
        etQuestionDesc = findViewById(R.id.et_question_desc)
        etQuestionDesc?.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
                checkAndUpdateCommitBtn()
            }

            override fun afterTextChanged(s: Editable) {}
        })
        btnCommit = findViewById(R.id.tv_commit)
        btnCommit?.setOnClickListener(View.OnClickListener { v: View? ->
            FeedbackServiceImpl.demoSuggest(
                userModel!!, tvDemoName?.text.toString(),
                etQuestionDesc?.text.toString(),
                *formatItemsForIntArray(questionTypeList)
            )
                .subscribe(object : ResourceSingleObserver<Boolean?>() {
                    override fun onSuccess(aBoolean: Boolean) {
                        if (aBoolean) {
                            ToastUtils.showShort(getString(R.string.app_feedback_success))
                            finish()
                        } else {
                            ToastUtils.showShort(getString(R.string.app_feedback_failed))
                        }
                    }

                    override fun onError(e: Throwable) {
                        ToastUtils.showShort(getString(R.string.app_feedback_failed))
                    }
                })
        })
    }

    override fun provideStatusBarConfig(): StatusBarConfig? {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .build()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == CODE_REQUEST_FOR_QUESTION && !onQuestionType(resultCode, data)) {
            return
        }
        if (requestCode == CODE_REQUEST_FOR_NAME && !onDemoName(resultCode, data)) {
            return
        }
        checkAndUpdateCommitBtn()
    }

    /**
     * 接收问题类型
     *
     * @return true 成功处理，false 处理失败
     */
    private fun onQuestionType(resultCode: Int, data: Intent?): Boolean {
        if (resultCode != RESULT_OK || data == null) {
            return false
        }
        questionTypeList.clear()
        val result =
            data.getSerializableExtra(QuestionTypeActivity.Companion.KEY_PARAM_QUESTION_TYPE_LIST) as ArrayList<QuestionItem>?
        if (result == null || result.isEmpty()) {
            tvQuestionType!!.text = ""
            checkAndUpdateCommitBtn()
            return false
        }
        questionTypeList.addAll(result)
        tvQuestionType!!.text = formatItemsForString(questionTypeList)
        return true
    }

    /**
     * 接收demo 名称
     *
     * @return true 成功处理，false 处理失败
     */
    private fun onDemoName(resultCode: Int, data: Intent?): Boolean {
        if (resultCode != RESULT_OK || data == null) {
            return false
        }
        val demoName = data.getStringExtra(DemoNameActivity.Companion.KEY_PARAM_DEMO_NAME)
        if (TextUtils.isEmpty(demoName)) {
            tvDemoName!!.text = ""
            checkAndUpdateCommitBtn()
            return false
        }
        tvDemoName!!.text = demoName
        return true
    }

    private fun checkAndUpdateCommitBtn() {
        val disable = (TextUtils.isEmpty(tvQuestionType!!.text)
                || TextUtils.isEmpty(etQuestionDesc!!.text.toString())
                || TextUtils.isEmpty(tvDemoName!!.text.toString()))
        btnCommit!!.isEnabled = !disable
    }

    private fun formatItemsForString(items: List<QuestionItem>): String {
        val builder = StringBuilder()
        for (item in items) {
            builder.append(item.name)
            builder.append("，")
        }
        val questionType = builder.toString()
        return questionType.substring(0, questionType.length - 1)
    }

    private fun formatItemsForIntArray(items: List<QuestionItem>): IntArray {
        val typeArray = IntArray(items.size)
        var i = 0
        for (item in items) {
            typeArray[i++] = item.id
        }
        return typeArray
    }

    companion object {
        private const val CODE_REQUEST_FOR_QUESTION = 1000
        private const val CODE_REQUEST_FOR_NAME = 1001
    }
}