/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.feedback

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.ExpandableListView
import android.widget.ImageView
import com.netease.yunxin.nertc.demo.R
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import com.netease.yunxin.nertc.demo.feedback.expand.QuestionGroup
import com.netease.yunxin.nertc.demo.feedback.expand.QuestionItem
import com.netease.yunxin.nertc.demo.feedback.expand.QuestionTypeAdapter
import java.util.*

/**
 * 问题类型选择页面
 */
class QuestionTypeActivity : BaseActivity() {
    private val questionTypeList = ArrayList<QuestionItem>()
    private val QUESTION_GROUPS = Arrays.asList(
        QuestionGroup(
            getString(R.string.app_audio_problem), Arrays.asList(
                QuestionItem(102, getString(R.string.app_audio_noise_or_instruments_sound)),
                QuestionItem(101, getString(R.string.app_audio_delay)),
                QuestionItem(103, getString(R.string.app_audio_off_and_on))
            )
        ),
        QuestionGroup(
            getString(R.string.app_video_problem), Arrays.asList(
                QuestionItem(106, getString(R.string.app_video_fuzzy)),
                QuestionItem(105, getString(R.string.app_video_block)),
                QuestionItem(107, getString(R.string.app_audio_video_not_sync))
            )
        )
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_question_type)
        paddingStatusBarHeight(findViewById(R.id.cl_root))
        val initList =
            intent.getSerializableExtra(KEY_PARAM_QUESTION_TYPE_LIST) as ArrayList<QuestionItem>?
        if (initList != null) {
            questionTypeList.clear()
            questionTypeList.addAll(initList)
        }
        initViews(initList)
    }

    private fun initViews(initList: List<QuestionItem>?) {
        val ivClose = findViewById<ImageView>(R.id.iv_close)
        ivClose.setOnClickListener { v: View? -> finish() }
        val rvQuestionList = findViewById<ExpandableListView>(R.id.rv_question_list)
        val adapter = QuestionTypeAdapter(this, QUESTION_GROUPS, initList)
        rvQuestionList.setAdapter(adapter)
        rvQuestionList.setOnChildClickListener { parent: ExpandableListView?, v: View, groupPosition: Int, childPosition: Int, id: Long ->
            val itemView = v.findViewById<View>(
                R.id.iv_chosen_icon
            )
            val item = QUESTION_GROUPS[groupPosition].items[childPosition]
            if (questionTypeList.contains(item)) {
                questionTypeList.remove(item)
                itemView.visibility = View.GONE
            } else {
                questionTypeList.add(item)
                itemView.visibility = View.VISIBLE
            }
            adapter.updateSelectedItem(item)
            true
        }
        val interactiveItem = QuestionItem(109, getString(R.string.app_interaction_experience))
        val tvInteractive = findViewById<View>(R.id.tv_interactive_question)
        val ivInteractive = findViewById<View>(R.id.iv_interactive_question)
        if (questionTypeList.contains(interactiveItem)) {
            ivInteractive.visibility = View.VISIBLE
        }
        tvInteractive.setOnClickListener { v: View? ->
            if (questionTypeList.contains(interactiveItem)) {
                questionTypeList.remove(interactiveItem)
                ivInteractive.visibility = View.GONE
            } else {
                questionTypeList.add(interactiveItem)
                ivInteractive.visibility = View.VISIBLE
            }
        }
        val otherItem = QuestionItem(99, getString(R.string.app_other_problem))
        val tvOther = findViewById<View>(R.id.tv_other_question)
        val ivOther = findViewById<View>(R.id.iv_other_question)
        if (questionTypeList.contains(otherItem)) {
            ivOther.visibility = View.VISIBLE
        }
        tvOther.setOnClickListener { v: View? ->
            if (questionTypeList.contains(otherItem)) {
                questionTypeList.remove(otherItem)
                ivOther.visibility = View.GONE
            } else {
                questionTypeList.add(otherItem)
                ivOther.visibility = View.VISIBLE
            }
        }
    }

    override fun provideStatusBarConfig(): StatusBarConfig? {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .build()
    }

    override fun finish() {
        val intent = Intent()
        intent.putExtra(KEY_PARAM_QUESTION_TYPE_LIST, questionTypeList)
        setResult(RESULT_OK, intent)
        super.finish()
    }

    companion object {
        const val KEY_PARAM_QUESTION_TYPE_LIST = "key_param_question_type_list"
        fun launchForResult(
            activity: Activity,
            requestCode: Int,
            questionList: ArrayList<QuestionItem>?
        ) {
            val intent = Intent(activity, QuestionTypeActivity::class.java)
            intent.putExtra(KEY_PARAM_QUESTION_TYPE_LIST, questionList)
            activity.startActivityForResult(intent, requestCode)
        }
    }
}