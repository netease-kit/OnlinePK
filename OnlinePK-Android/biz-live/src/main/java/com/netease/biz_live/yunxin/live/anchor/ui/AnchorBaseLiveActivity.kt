/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.ui

import android.hardware.Camera
import android.os.Bundle
import android.text.TextUtils
import android.view.*
import android.widget.*
import android.widget.TextView.OnEditorActionListener
import androidx.lifecycle.ViewModelProvider
import com.blankj.utilcode.util.*
import com.blankj.utilcode.util.PermissionUtils.FullCallback
import com.netease.biz_live.R
import com.netease.biz_live.databinding.LiveAnchorBaseLayoutBinding
import com.netease.biz_live.databinding.ViewIncludeRoomTopBinding
import com.netease.biz_live.yunxin.live.anchor.viewmodel.LiveBaseViewModel
import com.netease.biz_live.yunxin.live.audience.utils.*
import com.netease.biz_live.yunxin.live.audience.utils.InputUtils.InputParamHelper
import com.netease.biz_live.yunxin.live.audience.utils.StringUtils
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator
import com.netease.biz_live.yunxin.live.dialog.AnchorMoreDialog
import com.netease.biz_live.yunxin.live.dialog.AnchorMoreDialog.MoreItem
import com.netease.biz_live.yunxin.live.dialog.ChoiceDialog
import com.netease.biz_live.yunxin.live.dialog.DumpDialog
import com.netease.biz_live.yunxin.live.gift.GiftCache
import com.netease.biz_live.yunxin.live.ui.AudioControl
import com.netease.biz_live.yunxin.live.ui.BeautyControl
import com.netease.biz_live.yunxin.live.utils.ViewUtils
import com.netease.lava.nertc.sdk.NERtc
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.audio.NERtcVoiceBeautifierType
import com.netease.lava.nertc.sdk.audio.NERtcVoiceChangerType
import com.netease.lava.nertc.sdk.video.NERtcEncodeConfig.NERtcVideoFrameRate
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_live_room_service.impl.AudioOption
import com.netease.yunxin.lib_live_room_service.impl.VideoOption
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import com.netease.yunxin.lib_network_kt.network.ServiceCreator
import com.netease.yunxin.login.sdk.AuthorManager
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.BuildConfig
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig

/**
 * anchor base activity for live
 */
abstract class AnchorBaseLiveActivity : BaseActivity() {

    protected val roomService: LiveRoomService by lazy { LiveRoomService.sharedInstance() }

    //*******************直播参数*******************
    private var videoWidth = 960 //视频分辨率
    private var videoHeight = 540
    private var frameRate: NERtcVideoFrameRate =
        NERtcVideoFrameRate.FRAME_RATE_FPS_15 //码率
    private var audioScenario = NERtcConstants.AudioScenario.MUSIC //音频标准

    val baseViewBinding by lazy {
        LiveAnchorBaseLayoutBinding.inflate(layoutInflater)
    }

    val topViewBinding by lazy {
        ViewIncludeRoomTopBinding.bind(baseViewBinding.clyAnchorInfo)
    }

    /**
     * 美颜控制
     */
    private var beautyControl: BeautyControl? = null

    /**
     * 单主播直播信息
     */
    protected var liveInfo: LiveInfo? = null


    //音频控制
    protected var audioControl: AudioControl? = null

    var isMirror = true

    var voiceBeautifierEnable = false

    var audioEffectEnable = false

    /**
     * 直播开始
     */
    private var isLiveStart = false

    //摄像头FACE_BACK = 0, FACE_FRONT = 1
    var cameraFacing = Camera.CameraInfo.CAMERA_FACING_FRONT

    private val liveBaseViewModel by lazy {
        ViewModelProvider(
            this,
            ViewModelProvider.NewInstanceFactory()
        ).get(LiveBaseViewModel::class.java)
    }

    /**
     * 结束直播
     */
    private fun stopLiveErrorNetwork() {
        if (isLiveStart) {
            ToastUtils.showLong(R.string.biz_live_network_is_not_stable_live_is_end)
            finish()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 应用运行时，保持不锁屏、全屏化
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContentView(baseViewBinding.root)
        // 全屏展示控制
        paddingStatusBarHeight(findViewById(R.id.preview_anchor))
        paddingStatusBarHeight(findViewById(R.id.cly_anchor_info))
        paddingStatusBarHeight(findViewById(R.id.fly_container))
        ServiceCreator.setToken(AuthorManager.getUserInfo()?.accessToken)
        LiveRoomService.sharedInstance().setupWithOptions(
            this,
            BuildConfig.APP_KEY
        )
        requestPermissionsIfNeeded()
        //初始化伴音
        audioControl = AudioControl(this)
        audioControl?.initMusicAndEffect()

    }

    /**
     * 权限检查
     */
    private fun requestPermissionsIfNeeded() {
        val missedPermissions = NERtc.checkPermission(this)
        if (missedPermissions.size > 0) {
            PermissionUtils.permission(*missedPermissions.toTypedArray())
                .callback(object : FullCallback {
                    override fun onGranted(granted: MutableList<String?>) {
                        if (CollectionUtils.isEqualCollection(granted, missedPermissions)) {
                            initView()
                        }
                    }

                    override fun onDenied(
                        deniedForever: MutableList<String?>,
                        denied: MutableList<String?>
                    ) {
                        ToastUtils.showShort(R.string.biz_live_authorization_failed)
                        finish()
                    }
                }).request()
        } else {
            initView()
        }
    }

    protected open fun initView() {
        baseViewBinding.clyAnchorInfo.post {
            InputUtils.registerSoftInputListener(
                this@AnchorBaseLiveActivity,
                object : InputParamHelper {
                    override fun getHeight(): Int {
                        return baseViewBinding.clyAnchorInfo.height
                    }

                    override fun getInputView(): EditText {
                        return baseViewBinding.etRoomMsgInput
                    }
                })
        }
        initContainer()
        initData()
        setListener()
        initDataObserve()
        liveBaseViewModel.init()
    }

    protected abstract fun initContainer()

    protected open fun setListener() {
        baseViewBinding.ivMusic.setOnClickListener { showAudioControlDialog() }
        baseViewBinding.ivBeauty.setOnClickListener { showBeautyDialog() }
        baseViewBinding.tvRoomMsgInput.setOnClickListener {
            InputUtils.showSoftInput(
                baseViewBinding.etRoomMsgInput
            )
        }
        baseViewBinding.previewAnchor.btnLiveCreate?.setOnClickListener {
            it.isEnabled = false
            createLiveRoom(
                videoWidth, videoHeight, frameRate, audioScenario,
            )
        }
        baseViewBinding.previewAnchor.llyBeauty?.setOnClickListener { showBeautyDialog() }
        baseViewBinding.previewAnchor.llyFilter?.setOnClickListener { showFilterDialog() }
        baseViewBinding.previewAnchor.ivClose?.setOnClickListener { onBackPressed() }
        baseViewBinding.previewAnchor.ivSwitchCamera?.setOnClickListener { switchCamera() }
        baseViewBinding.ivMore.setOnClickListener { showLiveMoreDialog() }
        if (BuildConfig.DEBUG) {
            baseViewBinding.ivMore.setOnLongClickListener {
                DumpDialog.showDialog(supportFragmentManager)
                true
            }
        }
        baseViewBinding.etRoomMsgInput.setOnEditorActionListener(OnEditorActionListener { v: TextView?, actionId: Int, event: KeyEvent? ->
            if (v === baseViewBinding.etRoomMsgInput) {
                val input = baseViewBinding.etRoomMsgInput.text.toString()
                InputUtils.hideSoftInput(baseViewBinding.etRoomMsgInput)
                sendTextMsg(input)
                return@OnEditorActionListener true
            }
            false
        })
    }

    protected open fun initData() {
        beautyControl = BeautyControl(this)
        beautyControl?.initFaceUI()
        startPreview()
        roomService.getVideoOption().setupLocalVideoCanvas(baseViewBinding.videoView, false)
        //打开美颜
        beautyControl?.openBeauty()
        //添加网络监听回调
        NetworkUtils.registerNetworkStatusChangedListener(object :
            NetworkUtils.OnNetworkStatusChangedListener {
            override fun onDisconnected() {
                ALog.i(LOG_TAG, "network disconnected")
                onNetworkDisconnected()
            }

            override fun onConnected(networkType: NetworkUtils.NetworkType?) {
                onNetworkConnected(networkType)
                ALog.i(LOG_TAG, "network onConnected")
            }
        })
    }

    private fun setMirror() {
        isMirror = !isMirror
        baseViewBinding.videoView.setMirror(isMirror)
    }

    private fun setVoiceBeautifierPreset() {
        voiceBeautifierEnable = !voiceBeautifierEnable
        if (voiceBeautifierEnable) {
            //此处以VOICE_BEAUTIFIER_MAGNETIC 举例，更多效果请参考https://doc.yunxin.163.com/docs/jcyOTA0ODM/zk0MjA3Mzk?platformId=50002
            VideoOption.setVoiceBeautifierPreset(NERtcVoiceBeautifierType.VOICE_BEAUTIFIER_NATURE)
        } else {
            VideoOption.setVoiceBeautifierPreset(NERtcVoiceBeautifierType.VOICE_BEAUTIFIER_OFF)
        }

    }

    private fun setAudioEffectPreset() {
        audioEffectEnable = !audioEffectEnable
        if (audioEffectEnable) {
            //VOICE_CHANGER_EFFECT_MANTOLOLI 举例，更多效果请参考https://doc.yunxin.163.com/docs/jcyOTA0ODM/zk0MjA3Mzk?platformId=50002
            VideoOption.setAudioEffectPreset(NERtcVoiceChangerType.VOICE_CHANGER_EFFECT_MANTOLOLI)
        } else {
            VideoOption.setAudioEffectPreset(NERtcVoiceChangerType.AUDIO_EFFECT_OFF)
        }
    }

    protected open fun onNetworkDisconnected() {

    }

    protected open fun onNetworkConnected(networkType: NetworkUtils.NetworkType?) {

    }


    protected open fun initDataObserve() {
        liveBaseViewModel.rewardData.observe(this, {
            onUserReward(it)
        })
        liveBaseViewModel.errorData.observe(this, {
            if (it.serious) {
                finish()
            }
            ToastUtils.showLong(it.msg)
        })

        liveBaseViewModel.chatRoomMsgData.observe(this, {
            baseViewBinding.crvMsgList.appendItem(it)
        })

        liveBaseViewModel.kickedOutData.observe(this, {
            stopLiveErrorNetwork()
        })

        liveBaseViewModel.userAccountData.observe(this, {
            topViewBinding.tvAudienceCount.text = StringUtils.getAudienceCount(it)
        })

        liveBaseViewModel.audioEffectFinishData.observe(this, {
            onAudioEffectFinished(it)
        })

        liveBaseViewModel.audioMixingFinishData.observe(this, {
            if (it) {
                onAudioMixingFinished()
            }
        })

        liveBaseViewModel.audienceData.observe(this,{
            topViewBinding.rvAnchorPortraitList.updateAll(it)
        })
    }

    /**
     * on user reward to anchor
     */
    open fun onUserReward(reward: RewardMsg) {
        if (TextUtils.equals(reward.anchorReward.accountId, liveInfo?.anchor?.accountId)) {
            topViewBinding.tvAnchorCoinCount.text =
                StringUtils.getCoinCount(reward.anchorReward.rewardTotal)
            baseViewBinding.crvMsgList.appendItem(
                ChatRoomMsgCreator.createGiftReward(
                    reward.rewarderNickname,
                    1, GiftCache.getGift(reward.giftId).staticIconResId
                )
            )
        }
    }

    /**
     * switch the camera
     */
    protected fun switchCamera() {
        roomService.getVideoOption().switchCamera()
        cameraFacing = if (cameraFacing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
            Camera.CameraInfo.CAMERA_FACING_BACK
        } else {
            Camera.CameraInfo.CAMERA_FACING_FRONT
        }
        beautyControl?.switchCamera(cameraFacing)
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        val x = ev.rawX.toInt()
        val y = ev.rawY.toInt()
        // 键盘区域外点击收起键盘
        if (!ViewUtils.isInView(baseViewBinding.etRoomMsgInput, x, y) && isLiveStart) {
            InputUtils.hideSoftInput(baseViewBinding.etRoomMsgInput)
        }
        return super.dispatchTouchEvent(ev)
    }

    /**
     * 预览
     */
    private fun startPreview() {
        roomService.getVideoOption().startVideoPreview()
    }

    /**
     * create a live room
     */
    protected abstract fun createLiveRoom(
        width: Int,
        height: Int,
        frameRate: NERtcVideoFrameRate,
        audioScenario: Int
    )

    /**
     * 停止直播
     */
    private fun stopLive() {
        isLiveStart = false
        roomService.destroyRoom(object : NetRequestCallback<Unit> {
            override fun success(info: Unit?) {
                finish()
            }

            override fun error(code: Int, msg: String) {
                ALog.e(LOG_TAG, "destroyRoom error $msg code:$code")
                finish()
            }
        })
    }


    protected open fun onRoomLiveStart() {
        baseViewBinding.previewAnchor.visibility = View.GONE
        baseViewBinding.clyAnchorInfo.visibility = View.VISIBLE
        topViewBinding.tvAnchorNickname.text = liveInfo?.anchor?.nickname
        ImageLoader.with(applicationContext)
            .circleLoad(liveInfo?.anchor?.avatar, topViewBinding.ivAnchorPortrait)
        topViewBinding.tvAnchorCoinCount.setText(R.string.biz_live_zero_coin)
        isLiveStart = true
        baseViewBinding.flyContainer.visibility = View.VISIBLE
        topViewBinding.tvAudienceCount.text = StringUtils.getAudienceCount(0)
    }

    private fun onAudioEffectFinished(effectId: Int) {
        audioControl?.onEffectFinish(effectId)
    }

    private fun onAudioMixingFinished() {
        audioControl?.onMixingFinished()
    }

    fun onError(serious: Boolean, code: Int, msg: String?) {
        if (serious) {
            ToastUtils.showShort(msg)
            finish()
        }
        ALog.d(LOG_TAG, "$msg code = $code")
    }

    /**
     * 显示混音dailog
     */
    private fun showAudioControlDialog() {
        audioControl?.showAudioControlDialog()
    }

    /**
     * 展示美颜dialog
     */
    private fun showBeautyDialog() {
        beautyControl?.showBeautyDialog()
    }

    protected fun showFilterDialog() {
        beautyControl?.showFilterDialog()
    }


    private fun sendTextMsg(msg: String) {
        if (!TextUtils.isEmpty(msg.trim())) {
            roomService.sendTextMessage(msg)
            baseViewBinding.crvMsgList.appendItem(
                ChatRoomMsgCreator.createText(
                    true,
                    liveInfo?.anchor?.nickname,
                    msg
                )
            )
        }
    }

    protected open fun clearLocalImage() {
        baseViewBinding.videoView.clearImage()
    }


    /**
     * 直播中的更多弹框
     */
    private fun showLiveMoreDialog() {
        val anchorMoreDialog = AnchorMoreDialog(this)
        anchorMoreDialog.registerOnItemClickListener(object : AnchorMoreDialog.OnItemClickListener {
            override fun onItemClick(itemView: View?, item: MoreItem?): Boolean {
                when (item?.id) {
                    AnchorMoreDialog.ITEM_CAMERA -> {
                        if (item.enable) {
                            clearLocalImage()
                        }
                        return VideoOption.enableLocalVideo(!item.enable)
                    }
                    AnchorMoreDialog.ITEM_MUTE -> return AudioOption.muteLocalAudio(
                        item.enable
                    )
                    AnchorMoreDialog.ITEM_RETURN -> {
                        val result = AudioOption.enableEarBack(
                            !item.enable,
                            100
                        )
                        if (!result.first && !result.second) {
                            ToastUtils.showShort(R.string.biz_live_insert_earphones_before_open_earback)
                        }
                        return result.first
                    }
                    AnchorMoreDialog.ITEM_CAMERA_SWITCH -> switchCamera()
                    AnchorMoreDialog.ITEM_SETTING -> ToastUtils.showShort(R.string.biz_live_setting_function_to_be_improved)
                    AnchorMoreDialog.ITEM_DATA -> ToastUtils.showShort(R.string.biz_live_data_statistics_function_to_be_improved)
                    AnchorMoreDialog.ITEM_FINISH -> onBackPressed()
                    AnchorMoreDialog.ITEM_FILTER -> showFilterDialog()
                    else -> {
                    }
                }
                return true
            }

        })
        anchorMoreDialog.show()
    }

    override fun onBackPressed() {
        if (isLiveStart) {
            val closeDialog = ChoiceDialog(this)
                .setTitle(getString(R.string.biz_live_end_live))
                .setContent(getString(R.string.biz_live_sure_end_live))
                .setNegative(getString(R.string.biz_live_cancel), null)
                .setPositive(getString(R.string.biz_live_determine)) { stopLive() }
            closeDialog.show()
        } else {
            super.onBackPressed()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (beautyControl != null) {
            beautyControl?.onDestroy()
            beautyControl = null
        }
        AnchorMoreDialog.clearItem()
        LiveRoomService.destroyInstance()
        ALog.flush(true)
    }

    override fun provideStatusBarConfig(): StatusBarConfig? {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .build()
    }

    companion object {
        private const val LOG_TAG: String = "LiveBaseActivity"
    }
}