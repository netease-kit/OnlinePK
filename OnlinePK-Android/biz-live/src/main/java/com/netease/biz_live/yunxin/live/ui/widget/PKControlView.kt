/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui.widget

import android.content.Context
import android.os.CountDownTimer
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.Group
import androidx.constraintlayout.widget.Guideline
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.lib_live_room_service.bean.reward.RewardAudience

/**
 * Created by luc on 2020/11/23.
 *
 *
 * 用于控制 pk 浮层UI展示
 */
class PKControlView : FrameLayout {
    private var glPkRatio: Guideline? = null
    private var tvScore: TextView? = null
    private var tvOtherScore: TextView? = null
    private var tvCountTime: TextView? = null
    private var flVideoContainer: FrameLayout? = null
    private var pkRankingAdapter: InnerAdapter? = null
    private var otherPkRankingAdapter: InnerAdapter? = null
    private var pkResultFlag: ImageView? = null
    private var otherPkResultFlag: ImageView? = null
    private var tvOtherAnchorName: TextView? = null
    private var ivOtherAnchorPortrait: ImageView? = null
    private var gpOtherAnchorInfo: Group? = null

    var ivMuteOther: ImageView? = null

    constructor(context: Context) : super(context) {
        initView()
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        initView()
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        initView()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.view_pk_whole_layout, this, true)

        // pk 值对比百分比控制
        glPkRatio = findViewById(R.id.gl_pk_ration)

        // pk 值比分
        tvScore = findViewById(R.id.tv_pk_score)
        tvOtherScore = findViewById(R.id.tv_other_pk_score)

        // 倒计时view
        tvCountTime = findViewById(R.id.tv_countdown_time)

        /**
         * 静音对方主播
         */
        ivMuteOther = findViewById(R.id.iv_pk_mute)

        // 排行榜UI
        val rvRanking: RecyclerView = findViewById(R.id.rv_pk_ranking)
        rvRanking.layoutManager =
            LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        pkRankingAdapter = InnerAdapter(
            context, false
        )
        rvRanking.adapter = pkRankingAdapter
        val rvOtherRanking: RecyclerView = findViewById(R.id.rv_other_pk_ranking)
        rvOtherRanking.layoutManager =
            LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, true)
        otherPkRankingAdapter = InnerAdapter(
            context, true
        )
        rvOtherRanking.adapter = otherPkRankingAdapter

        // pk 结果图标
        pkResultFlag = findViewById(R.id.iv_pk_result)
        otherPkResultFlag = findViewById(R.id.iv_other_pk_result)

        // 视频播放容器
        flVideoContainer = findViewById(R.id.fl_group)

        // pk 主播信息
        tvOtherAnchorName = findViewById(R.id.tv_other_anchor_name)
        ivOtherAnchorPortrait = findViewById(R.id.iv_other_anchor_portrait)
        gpOtherAnchorInfo = findViewById(R.id.gp_other_anchor_info)
    }

    /**
     * 获取视频区域展示容器
     */
    fun getVideoContainer(): FrameLayout? {
        return flVideoContainer
    }

    /**
     * 更新主播信息
     *
     * @param name   主播名称
     * @param avatar 主播头像
     */
    fun updatePkAnchorInfo(name: String?, avatar: String?) {
        gpOtherAnchorInfo?.visibility = VISIBLE
        tvOtherAnchorName?.text = name
        ImageLoader.with(context.applicationContext).circleLoad(avatar, ivOtherAnchorPortrait)
    }

    /**
     * 设置分数变化
     *
     * @param score      当前主播分数
     * @param otherScore 对方主播分数
     */
    fun updateScore(score: Long, otherScore: Long) {
        tvScore?.text = score.toString()
        tvOtherScore?.text = otherScore.toString()
        // 如果有两方比分都为 0 则设置百分比为 0.5
        if (score == 0L && otherScore == 0L) {
            glPkRatio?.setGuidelinePercent(0.5f)
            return
        }
        val percent = score / (score + otherScore + 0f)
        glPkRatio?.setGuidelinePercent(percent)
    }

    /**
     * 处理pk 结果图标展示
     *
     * @param show          是否展示
     * @param anchorSuccess 当前主播是否胜利
     */
    fun handleResultFlag(show: Boolean, anchorSuccess: Int) {
        pkResultFlag?.visibility = if (show) VISIBLE else INVISIBLE
        otherPkResultFlag?.visibility = if (show) VISIBLE else INVISIBLE
        if (!show) {
            return
        }
        when (anchorSuccess) {
            PK_RESULT_FAILED -> {
                ImageLoader.with(context.applicationContext).load(R.drawable.icon_pk_success).into(otherPkResultFlag)
                ImageLoader.with(context.applicationContext).load(R.drawable.icon_pk_fail).into(pkResultFlag)
            }
            PK_RESULT_SUCCESS -> {
                ImageLoader.with(context.applicationContext).load(R.drawable.icon_pk_success).into(pkResultFlag)
                ImageLoader.with(context.applicationContext).load(R.drawable.icon_pk_fail).into(otherPkResultFlag)
            }
            PK_RESULT_DRAW -> {
                ImageLoader.with(context.applicationContext).load(R.drawable.icon_pk_draw).into(otherPkResultFlag)
                ImageLoader.with(context.applicationContext).load(R.drawable.icon_pk_draw).into(pkResultFlag)
            }
        }
    }

    /**
     * 倒计时控制器
     *
     * @param type 类型
     * @param leftMillis 倒计时时间
     */
    fun createCountDownTimer(type: String?, leftMillis: Long): WrapperCountDownTimer? {
        return WrapperCountDownTimer(leftMillis, object : TimerListener {
            override fun onStart(startTime: Long) {
                tvCountTime?.text = formatTime(type, startTime)
            }

            override fun onTick(millisUntilFinished: Long) {
                tvCountTime?.text = formatTime(type, millisUntilFinished)
            }

            override fun onStop() {
                tvCountTime?.text = formatTime(type, 0L)
            }
        })
    }

    /**
     * 格式化倒计时格式
     *
     * @param type 倒计时类型
     * @param timeMillis 时间，单位毫秒
     */
    private fun formatTime(type: String?, timeMillis: Long): String? {
        val timeSeconds = timeMillis / 1000L
        val timeMinute = timeSeconds / 60L
        val leftSeconds = timeSeconds % 60L
        return "$type $timeMinute:$leftSeconds"
    }

    /**
     * 更新排行榜数据
     *
     * @param audienceList      当前主播排行榜
     * @param otherAudienceList 对方主播排行榜
     */
    fun updateRanking(
        audienceList: List<RewardAudience?>?,
        otherAudienceList: List<RewardAudience?>?
    ) {
        pkRankingAdapter?.updateDataSource(audienceList)
        otherPkRankingAdapter?.updateDataSource(otherAudienceList)
    }

    /**
     * 重置pk 控制view
     */
    fun reset() {
        updateRanking(null, null)
        handleResultFlag(false, 0)
        updateScore(0, 0)
    }

    /**
     * 内部排行榜 adapter
     */
    private class InnerAdapter(context: Context?, private val other: Boolean) :
        LiveBaseAdapter<RewardAudience?>(context) {
        override fun getLayoutId(viewType: Int): Int {
            return R.layout.view_item_pk_ranking_audience
        }

        override fun onCreateViewHolder(itemView: View): LiveViewHolder {
            return LiveViewHolder(itemView)
        }

        override fun onBindViewHolder(
            holder: LiveViewHolder,
            itemData: RewardAudience?,
            position: Int
        ) {
            val ivPortrait = holder.getView<ImageView?>(R.id.iv_item_audience_portrait)
            ImageLoader.with(context?.applicationContext).circleLoad(itemData?.avatar, ivPortrait)
            ivPortrait?.isEnabled = !other
            val tvOrder = holder.getView<TextView?>(R.id.tv_item_audience_order)
            tvOrder?.text = (position + 1).toString()
            tvOrder?.isEnabled = !other
        }

        override fun getItemCount(): Int {
            return Math.min(super.getItemCount(), MAX_AUDIENCE_COUNT)
        }

        companion object {
            private const val MAX_AUDIENCE_COUNT = 3
        }
    }

    /**
     * 定时器封装
     */
    class WrapperCountDownTimer(
        private val leftTimeMillis: Long,
        private val timerListener: TimerListener?
    ) {
        private val countDownTimer: CountDownTimer?

        /**
         * 定时器停止
         */
        fun stop() {
            countDownTimer?.cancel()
            timerListener?.onStop()
        }

        /**
         * 定时器开始倒计时
         */
        fun start() {
            timerListener?.onStart(leftTimeMillis)
            countDownTimer?.start()
        }

        init {
            countDownTimer = object : CountDownTimer(leftTimeMillis, 1000L) {
                override fun onTick(millisUntilFinished: Long) {
                    timerListener?.onTick(millisUntilFinished)
                }

                override fun onFinish() {
                    timerListener?.onStop()
                }
            }
        }
    }

    /**
     * 内部定时器回调
     */
    interface TimerListener {
        open fun onStart(startTime: Long)
        open fun onTick(millisUntilFinished: Long)
        open fun onStop()
    }

    companion object {
        const val PK_RESULT_FAILED = -1
        const val PK_RESULT_SUCCESS = 1
        const val PK_RESULT_DRAW = 0
    }
}