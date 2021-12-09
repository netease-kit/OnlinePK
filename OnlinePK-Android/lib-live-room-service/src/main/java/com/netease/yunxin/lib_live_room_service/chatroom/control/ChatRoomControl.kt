/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.chatroom.control

import android.text.TextUtils
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.Observer
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.chatroom.ChatRoomMessageBuilder
import com.netease.nimlib.sdk.chatroom.ChatRoomService
import com.netease.nimlib.sdk.chatroom.ChatRoomServiceObserver
import com.netease.nimlib.sdk.chatroom.constant.MemberQueryType
import com.netease.nimlib.sdk.chatroom.model.*
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.constant.NotificationType
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.bean.LiveUser
import com.netease.yunxin.lib_live_room_service.chatroom.ChatRoomParserManager
import com.netease.yunxin.lib_live_room_service.chatroom.LiveAttachParser
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_live_room_service.chatroom.TextWithRoleAttachment
import com.netease.yunxin.lib_live_room_service.delegate.LiveRoomDelegate
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import java.util.*
import java.util.concurrent.atomic.AtomicInteger
import kotlin.collections.ArrayList

object ChatRoomControl {

    const val LOG_TAG = "ChatRoomControl"

    /**
     * 直播间展示最多在线观众信息数目
     */
    private const val MAX_AUDIENCE_COUNT = 10

    /**
     * 加入直播间的用户信息
     */
    private var liveUser: LiveUser? = null

    private var isAnchor: Boolean = false

    /**
     * 聊天室服务（IM SDK）
     */
    private val chatRoomService = NIMClient.getService(
        ChatRoomService::class.java
    )

    /**
     * 聊天室ID
     */
    private var roomId: String? = null

    private var delegate: LiveRoomDelegate? = null

    /**
     * 聊天室在线用户量
     */
    private val onlineUserCount: AtomicInteger = AtomicInteger(0)

    /**
     * 聊天室服务回调监听（IM SDK）
     */
    private val chatRoomMsgObserver: Observer<MutableList<ChatRoomMessage>> =
        Observer { chatRoomMessages ->
            if (chatRoomMessages.isEmpty()) {
                return@Observer
            }
            if (liveUser == null) {
                return@Observer
            }
            for (message in chatRoomMessages) {
                ALog.d(LOG_TAG, message.attachment.toString())
                // 只接收此聊天室的相应消息
                if (message.sessionType != SessionTypeEnum.ChatRoom ||
                    roomId != message.sessionId
                ) {
                    continue
                }
                // 聊天室通知消息处理（用户进入/离开，关闭）
                val attachment = message.attachment
                if (attachment is ChatRoomNotificationAttachment) {
                    handleChatroomNotification(attachment)
                    continue
                }

                // 聊天室文本消息处理
                if (attachment is TextWithRoleAttachment) {
                    delegate?.onRecvRoomTextMsg(
                        message.chatRoomMessageExtension.senderNick,
                        attachment
                    )
                    continue
                }

                // 打赏
                if (attachment is RewardMsg) {
                    delegate?.onUserReward(attachment)
                    continue
                }

            }
        }

    /**
     * 监听聊天室解散
     */
    private val chatRoomKickOutEventObserver: Observer<ChatRoomKickOutEvent?>? =
        Observer { chatRoomKickOutEvent ->
            if (chatRoomKickOutEvent == null) {
                return@Observer
            }
            ALog.d(
                LOG_TAG,
                "ChatRoom kickOut roomId:" + chatRoomKickOutEvent.roomId + " reason:" + chatRoomKickOutEvent.reason
            )
            if (chatRoomKickOutEvent.reason.value == ChatRoomKickOutEvent.ChatRoomKickOutReason.KICK_OUT_BY_CONFLICT_LOGIN.value) {
                delegate?.onKickedOut()
            } else {
                delegate?.onAnchorLeave()
            }
        }

    private fun handleChatroomNotification(notification: ChatRoomNotificationAttachment) {
        when (notification.type) {
            NotificationType.ChatRoomMemberIn -> {
                notifyUserIO(true, notification.targetNicks, notification.targets)
            }
            NotificationType.ChatRoomMemberExit -> {
                notifyUserIO(false, notification.targetNicks, notification.targets)
            }
            NotificationType.ChatRoomClose -> {
                delegate?.onRoomDestroy()
            }
            else -> {
            }
        }
    }

    /**
     * notify about user enter and left
     *
     * @param enter        true enter，false left
     * @param nicknameList nickname list
     */
    private fun notifyUserIO(
        enter: Boolean,
        nicknameList: MutableList<String>,
        imAccIdList: MutableList<String>
    ) {
        if (nicknameList.isEmpty() || imAccIdList.isEmpty()
            || nicknameList.size != imAccIdList.size
        ) {
            return
        }
        for (i in imAccIdList.indices) {
            val imAccId = imAccIdList[i]
            val nickname = nicknameList[i]
            if (TextUtils.equals(imAccId, liveUser?.imAccid)) {
                continue
            }
            if (enter) {
                onlineUserCount.incrementAndGet()
                delegate?.onUserEntered(nickname)
            } else {
                onlineUserCount.decrementAndGet()
                delegate?.onUserLeft(nickname)
            }
        }
        delegate?.onUserCountChange(onlineUserCount.get())
        queryRoomTempMembers(MAX_AUDIENCE_COUNT)
    }

    fun init(roomDelegate: LiveRoomDelegate) {
        this.delegate = roomDelegate
        listen(true)

    }

    fun destroy() {
        delegate = null
        onlineUserCount.set(0)
        listen(false)
    }

    /**
     * 注册/反注册 聊天室（IM SDK）
     *
     * @param register true 注册，false 反注册
     */
    private fun listen(register: Boolean) {
        NIMClient.getService(ChatRoomServiceObserver::class.java)
            .observeReceiveMessage(chatRoomMsgObserver, register)
        NIMClient.getService(ChatRoomServiceObserver::class.java)
            .observeKickOutEvent(chatRoomKickOutEventObserver, register)
    }

    /**
     * 查询聊天室成员列表
     *
     * @param size            查询数量
     */
    fun queryRoomTempMembers(
        size: Int
    ) {
        chatRoomService.fetchRoomMembers(roomId, MemberQueryType.GUEST, 0, size)
            .setCallback(object : RequestCallback<MutableList<ChatRoomMember>> {
                override fun onSuccess(param: MutableList<ChatRoomMember>) {

                    if (param.isEmpty()) {
                        delegate?.onAudienceChange(ArrayList())
                        return
                    }
                    val result: MutableList<LiveUser> = ArrayList(param.size)
                    for(roomMember in param){
                        val audience = LiveUser(
                            roomMember.account,
                            roomMember.account,
                            null,
                            roomMember.nick,
                            roomMember.avatar,
                            null
                        )
                        result.add(audience)
                    }
                    delegate?.onAudienceChange(result)
                }

                override fun onFailed(code: Int) {
                    ALog.e(LOG_TAG,"feat audience failed code$code")
                }

                override fun onException(exception: Throwable?) {
                    ALog.e(LOG_TAG, "feat audience failed exception:$exception")
                }
            })
    }

    /**
     * 加入聊天室
     */
    fun joinChatRoom(
        roomId: String,
        liveUser: LiveUser,
        isAnchor: Boolean,
        callback: NetRequestCallback<Unit>
    ) {
        this.roomId = roomId
        this.liveUser = liveUser
        this.isAnchor = isAnchor
        // 注册自定义消息类型解析器
        ChatRoomParserManager.addParser(LiveAttachParser)
        NIMClient.getService(MsgService::class.java)
            .registerCustomAttachmentParser(ChatRoomParserManager)
        val roomData = EnterChatRoomData(roomId)
        roomData.nick = liveUser.nickname
        roomData.avatar = liveUser.avatar
        chatRoomService.enterChatRoomEx(roomData, 1)
            .setCallback(object : RequestCallback<EnterChatRoomResultData> {
                /**
                 * 操作成功
                 * @param param 操作结果
                 */
                override fun onSuccess(param: EnterChatRoomResultData?) {
                    callback.success()
                    queryRoomInfoAndNotify()
                }

                /**
                 * 操作失败
                 * @param code 错误码。
                 */
                override fun onFailed(code: Int) {
                    ALog.d(LOG_TAG, "join chat room failed code$code,roomId:$roomId")
                    callback.error(code, "join chat room failed")
                }

                /**
                 * 操作过程中发生异常
                 * @param exception 异常详情
                 */
                override fun onException(exception: Throwable?) {
                    callback.error(msg = "join chat room exception")
                }
            })
    }

    /**
     * 更新聊天室用户数
     */
    private fun queryRoomInfoAndNotify() {
        chatRoomService.fetchRoomInfo(roomId)
            .setCallback(object : RequestCallback<ChatRoomInfo?> {
                override fun onSuccess(param: ChatRoomInfo?) {
                    if (param == null) {
                        return
                    }
                    // 获取主播 登录 imAccId
                    val anchorImAccId = param.creator
                    onlineUserCount.set((param.onlineUserCount - 1).coerceAtLeast(0))
                    // 查询主播在线情况
                    queryAnchorOnlineStatusAndNotify(anchorImAccId)
                }

                override fun onFailed(code: Int) {}
                override fun onException(exception: Throwable?) {}
            })
    }

    /**
     * 查询主播在线情况
     *
     * @param anchorImAccId 主播登录 im id
     */
    private fun queryAnchorOnlineStatusAndNotify(anchorImAccId: String?) {
        chatRoomService.fetchRoomMembersByIds(roomId, listOf(anchorImAccId))
            .setCallback(object : RequestCallback<MutableList<ChatRoomMember>> {
                override fun onSuccess(param: MutableList<ChatRoomMember>) {

                    // 主播不在线通知主播离开
                    val isAnchorOnline = param.isNotEmpty() && param[0].isOnline
                    if (!isAnchorOnline) {
                        delegate?.onAnchorLeave()
                    }
                    delegate?.onUserCountChange(onlineUserCount.get())
                }

                override fun onFailed(code: Int) {
                    delegate?.onAnchorLeave()
                }

                override fun onException(exception: Throwable?) {
                    delegate?.onAnchorLeave()
                }
            })
    }

    /**
     * 离开聊天室
     */
    fun leaveChatRoom() {
        chatRoomService.exitChatRoom(roomId)
        roomId = null
        ChatRoomParserManager.remove(LiveAttachParser)
    }

    /**
     * 发送文本消息
     */
    fun sendTextMsg(isAnchor: Boolean, msg: String) {
        val attachment = TextWithRoleAttachment(isAnchor, msg)
        chatRoomService.sendMessage(
            ChatRoomMessageBuilder.createChatRoomCustomMessage(roomId, attachment), false
        )
    }


    /**
     * 查询聊天室信息
     */
     fun queryChatRoomInfo(roomId: String,callback: NetRequestCallback<ChatRoomInfo>) {
        chatRoomService.fetchRoomInfo(roomId)
            .setCallback(object : RequestCallback<ChatRoomInfo?> {
                override fun onSuccess(param: ChatRoomInfo?) {
                    if (param == null) {
                        return
                    }
                    onlineUserCount.set((param.onlineUserCount - 1).coerceAtLeast(0))
                    callback.success(param)
                }

                override fun onFailed(code: Int) {
                    callback.error(code,"onFailed:$code")
                }
                override fun onException(exception: Throwable?) {
                    callback.error(-1,"onException:$exception")
                }
            })
    }
}