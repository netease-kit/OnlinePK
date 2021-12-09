/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Color
import android.text.TextUtils
import android.view.*
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.TextView
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.NetworkUtils
import com.blankj.utilcode.util.NetworkUtils.NetworkType
import com.blankj.utilcode.util.NetworkUtils.OnNetworkStatusChangedListener
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.databinding.ViewIncludeRoomTopBinding
import com.netease.biz_live.databinding.ViewItemAudienceLiveRoomInfoBinding
import com.netease.biz_live.yunxin.live.audience.ui.dialog.GiftDialog
import com.netease.biz_live.yunxin.live.audience.ui.dialog.GiftDialog.GiftSendListener
import com.netease.biz_live.yunxin.live.audience.ui.view.AudienceErrorStateView.ClickButtonListener
import com.netease.biz_live.yunxin.live.audience.utils.DialogHelperActivity
import com.netease.biz_live.yunxin.live.audience.utils.InputUtils
import com.netease.biz_live.yunxin.live.audience.utils.InputUtils.InputParamHelper
import com.netease.biz_live.yunxin.live.audience.utils.StringUtils
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator
import com.netease.biz_live.yunxin.live.floatplay.*
import com.netease.biz_live.yunxin.live.gift.GiftCache
import com.netease.biz_live.yunxin.live.gift.GiftRender
import com.netease.biz_live.yunxin.live.gift.ui.GifAnimationView
import com.netease.biz_live.yunxin.live.utils.SpUtils
import com.netease.biz_live.yunxin.live.utils.ViewUtils
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_live_room_service.bean.LiveUser
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_live_room_service.param.ErrorInfo
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig

/**
 * Created by luc on 2020/11/19.
 *
 *
 * 观众端详细控制，继承自[FrameLayout] 添加了 [TextureView] 以及 [ExtraTransparentView] 作为页面主要元素
 *
 *
 * TextureView 用于页面视频播放；
 *
 *
 * ExtraTransparentView 用于页面信息展示，由于页面存在左右横滑状态所以自定义view 继承自 [RecyclerView] 用于页面左右横滑支持；
 * // * 实际页面布局见 R.layout.view_item_audience_live_room_info
 *
 *
 *
 * 此处 [.prepare] 方法依赖于recyclerView 子 view 的 [androidx.recyclerview.widget.RecyclerView.onChildAttachedToWindow],
 * [androidx.recyclerview.widget.RecyclerView.onChildDetachedFromWindow] 方法，
 * 方法，[.renderData] 依赖于 [androidx.recyclerview.widget.RecyclerView.Adapter.onBindViewHolder]
 * 此处使用 [androidx.recyclerview.widget.LinearLayoutManager] 从源码角度可以保障 renderData 调用时机早于 prepare 时机。
 *
 */
@SuppressLint("ViewConstructor")
abstract class BaseAudienceContentView(val activity: BaseActivity) : FrameLayout(activity) {



    protected val roomService by lazy { LiveRoomService.sharedInstance() }


    /**
     * 礼物渲染控制，完成礼物动画的播放，停止，顺序播放等
     */
    private val giftRender: GiftRender = GiftRender()

    /**
     * 直播播放View
     */
    protected var videoView: CDNStreamTextureView? = null

    /**
     * 信息浮层左右切换
     */
    private var horSwitchView: ExtraTransparentView? = null

    /**
     * 观众端信息浮层，viewbinding 官方文档:https://developer.android.com/topic/libraries/view-bindinghl=zh-cn#java
     */
    protected val infoBinding by lazy {
        ViewItemAudienceLiveRoomInfoBinding.inflate(
            LayoutInflater.from(
                context
            ), this, false
        )
    }

    private val includeRoomTopBinding by lazy { ViewIncludeRoomTopBinding.bind(infoBinding.root) }

    /**
     * 主播错误状态展示（包含结束直播）
     */
    protected var errorStateView: AudienceErrorStateView? = null

    /**
     * 礼物弹窗
     */
    private var giftDialog: GiftDialog? = null

    private var joinRoomSuccess = false

    var audienceViewModel: AudienceViewModel? = null
    var roomDestroyed=false
    /**
     * 监听网络状态
     */
    private val onNetworkStatusChangedListener: OnNetworkStatusChangedListener =
        object : OnNetworkStatusChangedListener {
            override fun onDisconnected() {
                onNetworkDisconnected()
            }

            override fun onConnected(networkType: NetworkType) {
                onNetworkConnected(networkType)
            }
        }

    protected open fun onNetworkDisconnected() {
        ToastUtils.showLong(R.string.biz_live_network_error)
        ALog.d(LOG_TAG, "onDisconnected():" + System.currentTimeMillis())
        changeErrorState(true, AudienceErrorStateView.TYPE_ERROR)
        if (giftDialog?.isShowing == true) {
            giftDialog?.dismiss()
        }
    }

    protected open fun onNetworkConnected(networkType: NetworkType) {
        ALog.d(LOG_TAG, "onConnected():" + System.currentTimeMillis())
    }

    protected open fun showCdnView() {
        changeErrorState(false, -1)
        videoView?.visibility = VISIBLE
        // 初始化信息页面位置
        horSwitchView?.toSelectedPosition()
        // 聊天室信息更新到最新到最新一条
        infoBinding.crvMsgList.toLatestMsg()
        errorStateView?.visibility = GONE
    }

    open fun onUserRewardImpl(rewardInfo: RewardMsg) {
        if (TextUtils.equals(
                rewardInfo.anchorReward.accountId,
                audienceViewModel?.data!!.liveInfo?.anchor?.accountId
            )
        ) {
            refreshCoinCount(StringUtils.getCoinCount(rewardInfo.anchorReward.rewardTotal))
            giftRender.addGift(GiftCache.getGift(rewardInfo.giftId).dynamicIconResId)
        }
    }

    private fun refreshCoinCount(coinCount: String?) {
        coinCount?.let {
            includeRoomTopBinding.tvAnchorCoinCount.text =coinCount
        }
    }

    fun onMsgArrived(msg: CharSequence?) {
        infoBinding.crvMsgList.appendItem(msg)
    }


    /**
     * 错误页面按钮点击响应
     */
    private val clickButtonListener: ClickButtonListener = object : ClickButtonListener {
        override fun onBackClick(view: View?) {
            ALog.d(LOG_TAG, "onBackClick")
            finishLiveRoomActivity(true)
        }

        override fun onRetryClick(view: View?) {
            ALog.d(LOG_TAG, "onRetryClick")
            if (!NetworkUtils.isConnected()){
                ALog.d(LOG_TAG,"onRetryClick failed")
                return
            }
            if ( audienceViewModel?.data!!.liveInfo != null) {
                if (joinRoomSuccess) {
                    initLiveType(true)
                    select(audienceViewModel?.data!!.liveInfo!!)
                }
            }
        }
    }

    /**
     * 添加并初始化内部子 view
     */
    fun initViews() {
        ALog.d(LOG_TAG,"initViews()")
        // 设置 view 背景颜色
        setBackgroundColor(Color.parseColor("#ff201C23"))
        // 添加视频播放 TextureView
        videoView = CDNStreamTextureView(context)
        addView(videoView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        horSwitchView = ExtraTransparentView(context, infoBinding.root)
        // 页面左右切换时滑动到最新的消息内容
        horSwitchView?.registerSelectedRunnable { infoBinding.crvMsgList.toLatestMsg() }
        addView(
            horSwitchView,
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        // 浮层信息向下便宜 status bar 高度，避免重叠
        StatusBarConfig.paddingStatusBarHeight(activity, horSwitchView)

        // 添加错误状态浮层
        errorStateView = AudienceErrorStateView(context)
        addView(errorStateView)
        errorStateView?.visibility = GONE

        // 添加礼物展示浮层
        // 礼物动画渲染 view
        val gifAnimationView = GifAnimationView(context)
        val size = SpUtils.getScreenWidth(context)
        val layoutParams = generateDefaultLayoutParams()
        layoutParams.width = size
        layoutParams.height = size
        layoutParams.gravity = Gravity.BOTTOM
        layoutParams.bottomMargin = SpUtils.dp2pix(context, 166f)
        addView(gifAnimationView, layoutParams)
        gifAnimationView.bringToFront()
        // 绑定礼物渲染 view
        giftRender.init(gifAnimationView)

        // 监听软件盘弹起
        activity.let {
            InputUtils.registerSoftInputListener(it, object : InputParamHelper {
                override fun getHeight(): Int {
                    return this@BaseAudienceContentView.height
                }

                override fun getInputView(): EditText {
                    return infoBinding.etRoomMsgInput
                }
            })
        }

        infoBinding.apply {
            // 关闭按钮
            ivRoomClose.setOnClickListener {
                closeBtnClick()
            }
            // 礼物发送
            ivRoomGift.setOnClickListener {
                if (giftDialog == null) {
                    giftDialog = GiftDialog(activity)
                }
                giftDialog!!.show(object : GiftSendListener {
                    override fun onSendGift(giftId: Int?) {
                        giftId?.let {
                            roomService.reward(it, object : NetRequestCallback<Unit> {
                                override fun success(info: Unit?) {
                                    //do nothing
                                }

                                override fun error(code: Int, msg: String) {
                                    ToastUtils.showShort(R.string.biz_live_reward_failed)
                                }

                            })
                        }
                    }
                })
            }

            // 显示底部输入栏
            tvRoomMsgInput.setOnClickListener {
                InputUtils.showSoftInput(
                    infoBinding.etRoomMsgInput
                )
            }

            // 输入聊天框
            etRoomMsgInput.setOnEditorActionListener(TextView.OnEditorActionListener { v: TextView?, actionId: Int, event: KeyEvent? ->
                if (v === etRoomMsgInput) {
                    ALog.d(LOG_TAG,"audienceViewModel:"+audienceViewModel?.data!!.liveInfo.toString())
                    val input = etRoomMsgInput.text.toString()
                    InputUtils.hideSoftInput(etRoomMsgInput)
                    roomService.sendTextMessage(input)
                    audienceViewModel?.appendChatRoomMsg(
                        ChatRoomMsgCreator.createText(
                            false,
                            audienceViewModel?.data!!.liveInfo?.joinUserInfo?.nickname,
                            input
                        )
                    )
                    return@OnEditorActionListener true
                }
                false
            })
        }

    }

    /**
     * 页面信息，拉流，直播间信息展示等
     *
     * @param info 直播间信息
     */
    open fun renderData(info: LiveInfo) {




    }

    /**
     * 页面绑定准备
     */
    fun prepare() {
        showCdnView()
    }

    var roomId=""
    /**
     * 页面展示
     */
    fun select(liveInfo: LiveInfo) {
        roomId=liveInfo.live.roomId
        ALog.d(LOG_TAG,"select(),roomId:$roomId")
        audienceViewModel = ViewModelProvider(activity).get(AudienceViewModel::class.java)
        subscribeUI()
        if (!joinRoomSuccess&&!AudienceDataManager.hasCache(roomId)){
            roomService.enterRoom(roomId, object : NetRequestCallback<LiveInfo> {
                override fun success(info: LiveInfo?) {
                    ALog.d(LOG_TAG, "audience join room success,roomId:$roomId")
                    joinRoomSuccess = true
                    // 根据房间当前状态初始化房间信息
                    info?.let {
                        audienceViewModel?.refreshLiveInfo(info)
                    }
                    if (!roomDestroyed){
                        initLiveType(false)
                    }
                }

                override fun error(code: Int, msg: String) {
                    ToastUtils.showShort(msg)
                    ALog.e(LOG_TAG, "join room failed msg:$msg code= $code")
                    // 加入聊天室出现异常直接退出当前页面
                    finishLiveRoomActivity(true)
                }

            })
        }else{
            audienceViewModel?.queryRoomDetailInfo(liveInfo)
        }
        audienceViewModel?.select(liveInfo)
        if (!roomDestroyed&&AudienceDataManager.hasCache(roomId)){
            initLiveType(false)
        }
        videoView?.prepare(audienceViewModel?.data?.liveInfo)
    }

    fun saveListInfoAndPosition(infoList: MutableList<LiveInfo>, currentPosition: Int) {
        audienceViewModel?.saveListInfoAndPosition(infoList, currentPosition)
    }

    private val cacheObserver=Observer<AudienceData>{
            if (!needRefresh()){
                return@Observer
            }
            it?.let {
                ALog.d(LOG_TAG, "cacheObserver22:$it")
                refreshBasicUI(it.liveInfo)
                refreshAudienceCount(it.userCount)
                infoBinding.crvMsgList.appendItems(it.chatRoomMsgList as MutableList<CharSequence?>)
                refreshAudienceCount(it.userCount)
                refreshCoinCount(StringUtils.getCoinCount(it.rewardTotal))
                refreshUserList(it.userList)
                adjustVideoSize(it)
            }
    }

    open fun adjustVideoSize(data:AudienceData){

    }

    private val liveInfoObserver = Observer<LiveInfo> {
        if (!needRefresh()){
            return@Observer
        }
        ALog.d(LOG_TAG, "liveInfoObserver111,roomId:$roomId")
        ALog.d(LOG_TAG, "liveInfoObserver222,roomId:${it.live.roomId}")
        ALog.d(LOG_TAG, "liveInfoObserver333,chatRoomId:${it.live.chatRoomId}")
        ALog.d(LOG_TAG, "liveInfoObserver444,anchor:${it.anchor.nickname}")
        ALog.d(LOG_TAG, "liveInfoObserver444,audienceCount:${it.live.audienceCount}")
        refreshBasicUI(it)
    }

    private val errorInfoObserver = Observer<ErrorInfo> {
        if (!needRefresh()){
            return@Observer
        }
        ALog.d(LOG_TAG, "onError $it")
        if (it.serious) {
            finishLiveRoomActivity(true)
        } else {
            if (!TextUtils.isEmpty(it.msg)) {
                ToastUtils.showShort(it.msg)
            }
        }
    }

    private val errorStateObserver = Observer<Pair<Boolean, Int>> {
        if (!needRefresh()){
            return@Observer
        }
        roomDestroyed=it.first
        ALog.d(LOG_TAG,"roomDestroyed:$roomDestroyed")
        changeErrorState(it.first, it.second)
    }

    private val userCountObserver = Observer<Int> {
        if (!needRefresh()){
            return@Observer
        }
        refreshAudienceCount(it)

    }

    private val newChatRoomMsgObserver = Observer<CharSequence> {
        if (!needRefresh()){
            return@Observer
        }
        onMsgArrived(it)
    }
    private val kickedOutObserver = Observer<Boolean> {
        if (!needRefresh()){
            return@Observer
        }
        if (it) {
            finishLiveRoomActivity(true)
            context.startActivity(Intent(context, DialogHelperActivity::class.java))
        }
    }
    private val userRewardObserver = Observer<RewardMsg> {
        if (!needRefresh()){
            return@Observer
        }
        onUserRewardImpl(it)
    }
    private val videoHeightObserver = Observer<Int> {
        if (!needRefresh()){
            return@Observer
        }

    }
    private val userListObserver = Observer<MutableList<LiveUser>> {
        if (!needRefresh()){
            return@Observer
        }
        refreshUserList(it)
    }

    private fun refreshUserList(userList: MutableList<LiveUser>?) {
        userList?.let {
            includeRoomTopBinding.rvAnchorPortraitList.updateAll(userList)
        }
    }

    private fun refreshAudienceCount(count: Int) {
        includeRoomTopBinding.tvAudienceCount.text =
            StringUtils.getAudienceCount(count)
    }

    private fun refreshBasicUI(liveInfo: LiveInfo?) {
        liveInfo.let {
            errorStateView?.renderInfo(liveInfo?.anchor?.avatar, liveInfo?.anchor?.nickname)
            // 主播头像
            ImageLoader.with(context.applicationContext)
                .circleLoad(liveInfo?.anchor?.avatar, includeRoomTopBinding.ivAnchorPortrait)
            // 主播昵称
            includeRoomTopBinding.tvAnchorNickname.text = liveInfo?.anchor?.nickname
            includeRoomTopBinding.tvAnchorCoinCount.text =
                StringUtils.getCoinCount(liveInfo?.live?.rewardTotal!!)
        }
    }


    private fun subscribeUI() {
        ALog.d(LOG_TAG, "subscribeUI:$audienceViewModel")
        audienceViewModel?.apply {
            cacheData.observe(activity,cacheObserver)
            liveInfoData.observe(activity,liveInfoObserver)
            errorInfoData.observe(activity, errorInfoObserver)
            errorStateData.observe(activity, errorStateObserver)
            userCountData.observe(activity, userCountObserver)
            newChatRoomMsgData.observe(activity, newChatRoomMsgObserver)
            kickedOutData.observe(activity, kickedOutObserver)
            userRewardData.observe(activity, userRewardObserver)
            videoHeightData.observe(activity, videoHeightObserver)
            userListData.observe(activity, userListObserver)
        }

    }

    protected open fun initLiveType(isRetry: Boolean) {
        if (isRetry) {
            showCdnView()
            FloatPlayLogUtil.log(LOG_TAG, "initLiveType,showCdnView")
        }
        changeErrorState(false, -1)
    }


    /**
     * 页面资源释放
     */
    open fun release() {
        roomId=""
        unSubscribeUI()
        ALog.d(LOG_TAG,"leaveRoom")
        roomService.leaveRoom(object : NetRequestCallback<Unit> {
            override fun success(info: Unit?) {
                ALog.d(LOG_TAG,"leaveRoom success")
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showLong(msg)
                ALog.d(LOG_TAG,"leaveRoom error")
            }
        })
        // 礼物渲染释放
        giftRender.release()
        // 消息列表清空
        infoBinding.crvMsgList.clearAllInfo()
        joinRoomSuccess = false
    }

    private fun unSubscribeUI() {
        audienceViewModel?.apply {
            cacheData.removeObserver(cacheObserver)
            liveInfoData.removeObserver(liveInfoObserver)
            errorInfoData.removeObserver(errorInfoObserver)
            errorStateData.removeObserver(errorStateObserver)
            userCountData.removeObserver(userCountObserver)
            newChatRoomMsgData.removeObserver(newChatRoomMsgObserver)
            kickedOutData.removeObserver(kickedOutObserver)
            userRewardData.removeObserver(userRewardObserver)
            videoHeightData.removeObserver(videoHeightObserver)
            userListData.removeObserver(userListObserver)
        }
    }

    protected open fun changeErrorState(error: Boolean, type: Int) {
        FloatPlayLogUtil.log(LOG_TAG, "changeErrorState,error:$error,type:$type")
        if (error) {
            videoView?.visibility = GONE
            infoBinding.groupNormal.visibility= GONE
            errorStateView?.visibility= VISIBLE
            errorStateView?.updateType(type, clickButtonListener)
            if (type==AudienceErrorStateView.TYPE_FINISHED){
                release()
            }
        }else{
            roomDestroyed=false
            errorStateView?.visibility= GONE
            if (!roomDestroyed&&audienceViewModel?.data?.liveInfo!=null){
                infoBinding.groupNormal.visibility= VISIBLE
            }else{
                infoBinding.groupNormal.visibility= GONE
            }
        }
        if (roomDestroyed){
            InputUtils.hideSoftInput(infoBinding.etRoomMsgInput)
        }
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        val x = ev.rawX.toInt()
        val y = ev.rawY.toInt()
        // 键盘区域外点击收起键盘
        if (!ViewUtils.isInView(infoBinding.etRoomMsgInput, x, y)) {
            InputUtils.hideSoftInput(infoBinding.etRoomMsgInput)
        }
        return super.dispatchTouchEvent(ev)
    }


    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        NetworkUtils.registerNetworkStatusChangedListener(onNetworkStatusChangedListener)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        NetworkUtils.unregisterNetworkStatusChangedListener(onNetworkStatusChangedListener)
    }


    fun finishLiveRoomActivity(needRelease: Boolean) {
        if (needRelease) {
            release()
        }
        if (!activity.isFinishing) {
            activity.finish()
        }
    }

    private fun needRefresh():Boolean{
        val needRefresh=!TextUtils.isEmpty(roomId)&& roomId == audienceViewModel?.data?.liveInfo?.live?.roomId
        ALog.d(LOG_TAG,"needRefreshRoom,needRefresh:$needRefresh")
        return needRefresh
    }

    open fun closeBtnClick(){
        // 资源释放，页面退出
        val dialog=AudienceBottomTipsDialog()
        dialog.show(activity.supportFragmentManager, LOG_TAG)
        dialog.setClickCallback(object :AudienceBottomTipsDialog.OnClickCallback{
            override fun minimize() {
                if (FloatWindowPermissionManager.isFloatWindowOpAllowed(activity)) {
                    FloatPlayManager.startFloatPlay(
                        activity, roomId
                    )
                    finishLiveRoomActivity(false)
                } else {
                    FloatWindowPermissionManager.requestFloatWindowPermission(activity)
                }
            }

            override fun exit() {
                finishLiveRoomActivity(true)
            }

        })
    }

    companion object {
        const val LOG_TAG = "BaseAudienceContentView"
    }

    init {
        initViews()
    }
}