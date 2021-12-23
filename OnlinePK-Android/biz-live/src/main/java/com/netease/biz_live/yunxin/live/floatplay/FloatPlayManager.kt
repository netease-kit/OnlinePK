package com.netease.biz_live.yunxin.live.floatplay

import android.content.Context
import android.graphics.SurfaceTexture
import android.widget.FrameLayout
import com.blankj.utilcode.util.Utils
import com.netease.biz_live.yunxin.live.audience.ui.LiveAudienceActivity
import com.netease.biz_live.yunxin.live.audience.ui.LiveAudienceActivity.Companion.launchAudiencePage
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator
import com.netease.biz_live.yunxin.live.floatplay.FloatPlayLogUtil.log
import com.netease.biz_live.yunxin.live.gift.GiftCache
import com.netease.biz_live.yunxin.live.utils.SysUtil
import com.netease.biz_live.yunxin.live.utils.SpUtils.getScreenHeight
import com.netease.biz_live.yunxin.live.utils.SpUtils.getScreenWidth
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_live_room_service.LiveTypeManager
import com.netease.yunxin.lib_live_room_service.bean.LiveUser
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_live_room_service.chatroom.TextWithRoleAttachment
import com.netease.yunxin.lib_live_room_service.delegate.LiveRoomDelegate
import com.netease.yunxin.lib_live_room_service.param.ErrorInfo

object FloatPlayManager {
    private const val TAG = "FloatPlayManager"
    private var mIsShowing = false
    private var floatPlayLayout: FloatPlayLayout? = null
    private var floatView: FloatView? = null
    private var currentLiveType = Constants.LiveType.LIVE_TYPE_DEFAULT
    var flotWindowWidth = 0
    var flotWindowHeight = 0
    var roomId=""
    private val roomDelegate=object :LiveRoomDelegate{
        override fun onError(errorInfo: ErrorInfo) {
            ALog.d(TAG,"onError:$errorInfo")
            closeFloatPlay()
        }

        override fun onRoomDestroy() {
            ALog.d(TAG,"onRoomDestroy")
            closeFloatPlay()
        }

        override fun onUserCountChange(userCount: Int) {
            ALog.d(TAG,"onUserCountChange:$userCount")
            if (AudienceDataManager.hasCache(roomId)){
                AudienceDataManager.getDataFromCache()?.userCount=userCount
            }
        }

        override fun onRecvRoomTextMsg(nickname: String, attachment: TextWithRoleAttachment) {
            ALog.d(TAG,"onRecvRoomTextMsg:$nickname,msg:"+attachment.msg)
            if (AudienceDataManager.hasCache(roomId)){
                val msg = ChatRoomMsgCreator.createText(
                    attachment.isAnchor,
                    nickname,
                    attachment.msg
                )
                AudienceDataManager.getDataFromCache()?.chatRoomMsgList?.add(msg)
            }
        }

        override fun onUserEntered(nickname: String) {
            ALog.d(TAG,"onUserEntered:$nickname")
            if (AudienceDataManager.hasCache(roomId)){
                val msg = ChatRoomMsgCreator.createRoomEnter(nickname)
                AudienceDataManager.getDataFromCache()?.chatRoomMsgList?.add(msg)
            }
        }

        override fun onUserLeft(nickname: String) {
            ALog.d(TAG,"onUserLeft:$nickname")
            if (AudienceDataManager.hasCache(roomId)){
                val msg = ChatRoomMsgCreator.createRoomExit(nickname)
                AudienceDataManager.getDataFromCache()?.chatRoomMsgList?.add(msg)
            }

        }

        override fun onKickedOut() {
            ALog.d(TAG,"onKickedOut")
            closeFloatPlay()
        }

        override fun onAnchorLeave() {
            ALog.d(TAG,"onAnchorLeave")
            closeFloatPlay()
        }

        override fun onUserReward(rewardInfo: RewardMsg) {
            ALog.d(TAG,"onUserReward:$rewardInfo")
            if (AudienceDataManager.hasCache(roomId)){
                val msg = ChatRoomMsgCreator.createGiftReward(
                    rewardInfo.rewarderNickname,
                    1, GiftCache.getGift(rewardInfo.giftId).staticIconResId
                )
                AudienceDataManager.getDataFromCache()?.rewardTotal=rewardInfo.anchorReward.rewardTotal
                AudienceDataManager.getDataFromCache()?.chatRoomMsgList?.add(msg!!)
            }
        }

        override fun onAudioEffectFinished(effectId: Int) {

        }

        override fun onAudioMixingFinished() {

        }

        override fun onAudienceChange(infoList: MutableList<LiveUser>) {
            ALog.d(TAG,"onAudienceChange:$infoList")
            if (AudienceDataManager.hasCache(roomId)){
                AudienceDataManager.getDataFromCache()?.userList=infoList
            }
        }

    }

    private val playerNotify: LiveVideoPlayerManager.PlayerNotify =
        object : LiveVideoPlayerManager.PlayerNotify {
            override fun onPreparing() {}
            override fun onPlaying() {}
            override fun onError() {

            }

            override fun onVideoSizeChanged(width: Int, height: Int) {
                if (floatPlayLayout != null) {
                    if (!isStartFloatWindow) {
                        return
                    }
                    AudienceDataManager.getDataFromCache()?.videoInfo?.videoWidth=width
                    AudienceDataManager.getDataFromCache()?.videoInfo?.videoHeight=height
                    if (CDNStreamTextureView.isPkSize(width, height)) {
                        flotWindowWidth = FloatPlayLayout.PK_LIVE_WIDTH
                        flotWindowHeight = FloatPlayLayout.PK_LIVE_HEIGHT
                        currentLiveType = Constants.LiveType.LIVE_TYPE_PK
                    } else {
                        flotWindowWidth = FloatPlayLayout.SINGLE_ANCHOR_WIDTH
                        flotWindowHeight = FloatPlayLayout.SINGLE_ANCHOR_HEIGHT
                        currentLiveType = Constants.LiveType.LIVE_TYPE_DEFAULT
                    }
                    floatView?.update(flotWindowWidth, flotWindowHeight)
                }
            }

            override fun onSurfaceTextureAvailable(
                surface: SurfaceTexture,
                width: Int,
                height: Int
            ) {
            }
        }

    fun startFloatPlay(context: Context, roomId: String) {
        mIsShowing = true
        this.roomId=roomId
        ALog.d(TAG, "startFloatPlay,roomId:$roomId")
        this.currentLiveType = LiveTypeManager.getCurrentLiveType()
        if (LiveTypeManager.getCurrentLiveType()== Constants.LiveType.LIVE_TYPE_DEFAULT
            &&CDNStreamTextureView.isSingleAnchorSize(AudienceDataManager.getDataFromCache()?.videoInfo?.videoWidth!!
                ,AudienceDataManager.getDataFromCache()?.videoInfo?.videoHeight!!)) {
            flotWindowWidth = FloatPlayLayout.SINGLE_ANCHOR_WIDTH
            flotWindowHeight = FloatPlayLayout.SINGLE_ANCHOR_HEIGHT
        } else if (LiveTypeManager.getCurrentLiveType()== Constants.LiveType.LIVE_TYPE_PK
            &&CDNStreamTextureView.isPkSize(AudienceDataManager.getDataFromCache()?.videoInfo?.videoWidth!!
                ,AudienceDataManager.getDataFromCache()?.videoInfo?.videoHeight!!)){
            flotWindowWidth = FloatPlayLayout.PK_LIVE_WIDTH
            flotWindowHeight = FloatPlayLayout.PK_LIVE_HEIGHT
        }
        log(TAG, "currentLiveType:$currentLiveType")
        floatPlayLayout = FloatPlayLayout(context.applicationContext)
        floatView = FloatView(context.applicationContext)
        floatView?.layoutParams = FrameLayout.LayoutParams(flotWindowWidth, flotWindowHeight)
        floatView?.addView(floatPlayLayout)
        floatView?.addToWindow()
        floatView?.setOnFloatViewClickListener(object : FloatView.OnFloatViewClickListener {
            override fun onClick() {
                if (!SysUtil.isAppRunningForeground(context)){
                    SysUtil.wakeupAppToForeground(context,LiveAudienceActivity::class.java)
                }
                launchAudiencePage(
                    context,
                    AudienceDataManager.getDataFromCache()?.infoList,
                    AudienceDataManager.getDataFromCache()?.currentPosition!!
                )
            }

        })
        floatView?.update(
            flotWindowWidth,
            flotWindowHeight,
            getScreenWidth(Utils.getApp()) - FloatPlayLayout.MARGIN_RIGHT - flotWindowWidth,
            getScreenHeight(Utils.getApp()) - FloatPlayLayout.MARGIN_BOTTOM - flotWindowHeight
        )
        val videoView = floatPlayLayout!!.videoView
        LiveVideoPlayerManager.getInstance().addVideoPlayerObserver(playerNotify)
        LiveVideoPlayerManager.getInstance().startPlay(
            AudienceDataManager.getDataFromCache()?.liveInfo!!.live.liveConfig.rtmpPullUrl,
            videoView!!
        )
        floatPlayLayout?.setPlayUrl(AudienceDataManager.getDataFromCache()?.liveInfo!!.live.liveConfig.rtmpPullUrl)
        log(TAG, " startFloatPlay:$mIsShowing")
        LiveRoomService.sharedInstance().addDelegate(roomDelegate)
    }

    fun stopFloatPlay() {
        if (!mIsShowing) {
            log(TAG, "stopFloatPlay return mIsShowing:$mIsShowing")
            return
        }
        floatView?.removeFromWindow()
        LiveRoomService.sharedInstance().removeDelegate(roomDelegate)
        mIsShowing = false
        log(TAG, "stopFloatPlay mIsShowing:$mIsShowing")
    }

    val isStartFloatWindow: Boolean
        get() {
            log(TAG, "isStartFloatWindow:$mIsShowing")
            return mIsShowing
        }

    fun release() {
        log(TAG, "release()")
        mIsShowing = false
        floatView = null
        floatPlayLayout = null
        LiveVideoPlayerManager.getInstance().removeVideoPlayerObserver(playerNotify)
    }

    fun closeFloatPlay(){
        floatPlayLayout?.release()
    }
}