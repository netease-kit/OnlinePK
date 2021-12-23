package com.netease.biz_live.yunxin.live.floatplay

import android.app.Application
import android.graphics.SurfaceTexture
import android.text.TextUtils
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.MutableLiveData
import com.netease.biz_live.yunxin.live.audience.ui.view.AudienceErrorStateView
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator
import com.netease.biz_live.yunxin.live.gift.GiftCache
import com.netease.nimlib.sdk.chatroom.model.ChatRoomInfo
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_live_room_service.bean.LiveUser
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_live_room_service.chatroom.TextWithRoleAttachment
import com.netease.yunxin.lib_live_room_service.delegate.LiveRoomDelegate
import com.netease.yunxin.lib_live_room_service.param.ErrorInfo
import com.netease.yunxin.lib_live_room_service.repository.LiveRoomRepository
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import com.netease.yunxin.lib_network_kt.network.Request
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class AudienceViewModel(application: Application) : AndroidViewModel(application) {

    companion object {
        private const val TAG = "AudienceViewModel"
    }

    /**
     * 直播间基本信息
     */
    val liveInfoData by lazy {
        MutableLiveData<LiveInfo>()
    }

    val userListData by lazy {
        MutableLiveData<MutableList<LiveUser>>()
    }

    val kickedOutData by lazy {
        MutableLiveData<Boolean>()
    }

    val userRewardData by lazy {
        MutableLiveData<RewardMsg>()
    }

    val newChatRoomMsgData by lazy {
        MutableLiveData<CharSequence>()
    }

    /**
     * 正在播放视频的高度，维护大窗，小窗单主播与PK主播的UI切换
     */
    val videoHeightData by lazy {
        MutableLiveData<Int>()
    }

    val errorInfoData by lazy {
        MutableLiveData<ErrorInfo>()
    }

    val errorStateData by lazy {
        MutableLiveData<Pair<Boolean, Int>>()
    }

    val userCountData by lazy {
        MutableLiveData<Int>()
    }

    var data: AudienceData? = null
    val cacheData by lazy {
        MutableLiveData<AudienceData>()
    }


    private val roomDelegate = object : LiveRoomDelegate {
        override fun onError(errorInfo: ErrorInfo) {
            errorInfoData.value = errorInfo
            FloatPlayLogUtil.log(TAG, "onError")
        }

        override fun onRoomDestroy() {
            errorStateData.value =
                Pair(true, AudienceErrorStateView.TYPE_FINISHED)
            FloatPlayLogUtil.log(TAG, "onRoomDestroy")

        }

        override fun onUserCountChange(userCount: Int) {
            userCountData.value = userCount
            FloatPlayLogUtil.log(TAG, "onUserCountChange:$userCount")
            data?.userCount = userCount
            saveCache()
        }

        override fun onRecvRoomTextMsg(nickname: String, attachment: TextWithRoleAttachment) {
            val msg = ChatRoomMsgCreator.createText(
                attachment.isAnchor,
                nickname,
                attachment.msg
            )
            data?.chatRoomMsgList?.add(msg)
            newChatRoomMsgData.value = msg
            FloatPlayLogUtil.log(TAG, "onRecvRoomTextMsg,size:" + data?.chatRoomMsgList?.size)
            saveCache()
        }

        override fun onUserEntered(nickname: String) {
            if (!TextUtils.equals(nickname, data?.liveInfo?.anchor?.nickname)) {
                val msg = ChatRoomMsgCreator.createRoomEnter(nickname)
                data?.chatRoomMsgList?.add(msg)
                newChatRoomMsgData.value = msg
                FloatPlayLogUtil.log(TAG, "onUserEntered")
                saveCache()
            }
        }

        override fun onUserLeft(nickname: String) {
            if (!TextUtils.equals(nickname, data?.liveInfo?.anchor?.nickname)) {
                val msg = ChatRoomMsgCreator.createRoomExit(nickname)
                data?.chatRoomMsgList?.add(msg)
                newChatRoomMsgData.value = msg
                FloatPlayLogUtil.log(TAG, "onUserLeft")
                saveCache()
            }
        }

        override fun onKickedOut() {
            kickedOutData.value = true
            FloatPlayLogUtil.log(TAG, "onKickedOut")
        }

        override fun onAnchorLeave() {
            errorStateData.value =
                Pair(true, AudienceErrorStateView.TYPE_FINISHED)
            FloatPlayLogUtil.log(TAG, "onAnchorLeave,audienceViewModel:")
            FloatPlayLogUtil.log(TAG, "onAnchorLeave,errorStateData:$errorStateData")
        }

        override fun onUserReward(rewardInfo: RewardMsg) {
            val msg = ChatRoomMsgCreator.createGiftReward(
                rewardInfo.rewarderNickname,
                1, GiftCache.getGift(rewardInfo.giftId).staticIconResId
            )
            data?.chatRoomMsgList?.add(msg!!)
            newChatRoomMsgData.value = msg
            userRewardData.value = rewardInfo
            data?.rewardTotal=rewardInfo.anchorReward.rewardTotal
            FloatPlayLogUtil.log(TAG, "onUserReward")
            saveCache()
        }

        override fun onAudioEffectFinished(effectId: Int) {}
        override fun onAudioMixingFinished() {}
        override fun onAudienceChange(infoList: MutableList<LiveUser>) {
            userListData.value = infoList
            data?.userList = infoList
            saveCache()
        }
    }

    private val playNotify: LiveVideoPlayerManager.PlayerNotify =
        object : LiveVideoPlayerManager.PlayerNotify {
            override fun onPreparing() {
                FloatPlayLogUtil.log(TAG, "video play onPreparing()")
            }

            override fun onPlaying() {
                FloatPlayLogUtil.log(TAG, "video play onPlaying()")
            }

            override fun onError() {
                FloatPlayLogUtil.log(TAG, "video play onError()")
                errorStateData.value =
                    Pair(true, AudienceErrorStateView.TYPE_ERROR)
            }

            override fun onVideoSizeChanged(width: Int, height: Int) {
                FloatPlayLogUtil.log(TAG, "onVideoSizeChanged(),width:$width,height:$height")
                videoHeightData.value = height
                data?.videoInfo?.videoWidth = width
                data?.videoInfo?.videoHeight = height
                saveCache()
            }

            override fun onSurfaceTextureAvailable(
                surface: SurfaceTexture,
                width: Int,
                height: Int
            ) {
            }

        }

    fun select(liveInfo: LiveInfo) {
        val roomId = liveInfo.live.roomId
        if (AudienceDataManager.hasCache(roomId)) {
            data = AudienceDataManager.getDataFromCache()
            cacheData.value = data
            FloatPlayLogUtil.log(TAG, "select has cache:" + data.toString())
        } else {
            data = AudienceData()
            FloatPlayLogUtil.log(TAG, "select no cache:")
            data?.liveInfo = liveInfo
            liveInfoData.value = liveInfo
            saveCache()
        }
        AudienceDataManager.setRoomId(roomId)
        // 监听房间信息，把相关UI需要用到的数据传到直播间
        LiveRoomService.sharedInstance().addDelegate(roomDelegate)
        if (LiveVideoPlayerManager.getInstance().containsVideoPlayerObserver(playNotify)) {
            LiveVideoPlayerManager.getInstance()
                .removeVideoPlayerObserver(playNotify)
        }
        LiveVideoPlayerManager.getInstance()
            .addVideoPlayerObserver(playNotify)
    }

    fun appendChatRoomMsg(msg: CharSequence) {
        data?.chatRoomMsgList?.add(msg)
        newChatRoomMsgData.value = msg
        FloatPlayLogUtil.log(TAG, "appendChatRoomMsg")
    }

    override fun onCleared() {
        super.onCleared()
        FloatPlayLogUtil.log(TAG, "onCleared()")
        LiveRoomService.sharedInstance().removeDelegate(roomDelegate)
        LiveVideoPlayerManager.getInstance()
            .removeVideoPlayerObserver(playNotify)
    }

    fun saveListInfoAndPosition(infoList: MutableList<LiveInfo>, currentPosition: Int) {
        data?.infoList = infoList as ArrayList<LiveInfo>
        data?.currentPosition = currentPosition
        saveCache()
    }

    fun refreshLiveInfo(liveInfo: LiveInfo) {
        data?.liveInfo = liveInfo
        saveCache()
    }

    fun queryRoomDetailInfo(liveInfo: LiveInfo){
        queryLiveRoomInfo(liveInfo)
        queryChatRoomInfo(liveInfo)
    }

    private fun queryLiveRoomInfo(liveInfo: LiveInfo) {
        CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate).launch {
            Request.request({
                LiveRoomRepository.enterRoom(liveInfo.live.roomId)
            }, success = {
                it?.let {
                    liveInfoData.value = it
                    data?.liveInfo=it
                    saveCache()
                    FloatPlayLogUtil.log(TAG,"queryLiveRoomInfo success:$it")
                }
            }, error = { code: Int, msg: String ->
                errorInfoData.value= ErrorInfo(false,code,msg)
            })
        }
    }

    private fun queryChatRoomInfo(liveInfo: LiveInfo){
        LiveRoomService.sharedInstance().queryChatRoomInfo(liveInfo.live.chatRoomId,object : NetRequestCallback<ChatRoomInfo> {
            override fun success(info: ChatRoomInfo?) {
                info?.let {
                    var audienceCount=info.onlineUserCount-1
                    if (audienceCount<0){
                        audienceCount=0
                    }
                    userCountData.value = audienceCount
                    data?.userCount=audienceCount
                    saveCache()
                    FloatPlayLogUtil.log(TAG,"queryChatRoomInfo audienceCount:$audienceCount")
                }
            }

            override fun error(code: Int, msg: String) {
                FloatPlayLogUtil.log(TAG,"queryChatRoomInfo error,code:$code,msg:$msg")
            }

        })
    }

    fun saveCache() {
        data?.let {
            AudienceDataManager.setDataToCache(data!!)
        }
    }
}