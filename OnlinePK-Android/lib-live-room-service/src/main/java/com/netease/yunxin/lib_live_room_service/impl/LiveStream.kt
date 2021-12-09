/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.impl

import android.graphics.Color
import com.netease.lava.nertc.impl.RtcCode
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.live.NERtcLiveConfig
import com.netease.lava.nertc.sdk.live.NERtcLiveStreamLayout
import com.netease.lava.nertc.sdk.live.NERtcLiveStreamTaskInfo
import com.netease.lava.nertc.sdk.live.NERtcLiveStreamUserTranscoding
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.param.LiveStreamTaskRecorder
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import java.util.*

/**
 * live stream function
 */
class LiveStream {
    companion object {

        private const val LOG_TAG = "LiveStream"

        /**
         * 添加推流任务
         *
         * @param liveRecoder
         * @return
         */
        fun addLiveStreamTask(liveRecoder: LiveStreamTaskRecorder): Int {
            //初始化task
            val liveTask = getStreamTask(liveRecoder)
            liveTask.layout = getSignalAnchorStreamLayout(liveRecoder)
            ALog.d(
                LOG_TAG,
                "addLiveStreamTask recoder = $liveRecoder"
            )
            val ret: Int = NERtcEx.getInstance().addLiveStreamTask(
                liveTask
            ) { s: String?, code: Int ->
                if (code == RtcCode.LiveCode.OK) {
                    ALog.d(
                        LOG_TAG,
                        "addLiveStream success : taskId " + liveRecoder.taskId
                    )
                } else {
                    ALog.d(
                        LOG_TAG,
                        "addLiveStream failed : taskId " + liveRecoder.taskId + " , code : " + code
                    )
                }
            }
            if (ret != 0) {
                ALog.d(
                    LOG_TAG,
                    "addLiveStream failed : taskId " + liveRecoder.taskId + " , ret : " + ret
                )
            }
            return ret
        }

        fun updateStreamTask(task: NERtcLiveStreamTaskInfo,callback: NetRequestCallback<Int>?=null): Int {
            val ret: Int = NERtcEx.getInstance().updateLiveStreamTask(
                task
            ) { s: String?, code: Int ->
                if (code == RtcCode.LiveCode.OK) {
                    ALog.d(
                        LOG_TAG,
                        "updateStreamTask success : taskId " + task.taskId
                    )
                    callback?.success(RtcCode.LiveCode.OK)
                } else {
                    ALog.d(
                        LOG_TAG,
                        "updateStreamTask failed : taskId " + task.taskId + " , code : " + code
                    )
                    callback?.error(code,s+"")
                }
            }
            if (ret != 0) {
                ALog.d(
                    LOG_TAG,
                    "updateStreamTask failed : taskId " + task.taskId + " , ret : " + ret
                )
                callback?.error(-1,"updateLiveStreamTask return none zero")
            }
            return ret
        }

        /**
         * get a live stream task
         */
        fun getStreamTask(liveRecoder: LiveStreamTaskRecorder): NERtcLiveStreamTaskInfo {
            //初始化task
            val liveTask = NERtcLiveStreamTaskInfo()
            //taskID 可选字母、数字，下划线，不超过64位
            liveTask.taskId = liveRecoder.taskId
            // 一个推流地址对应一个推流任务
            liveTask.url = liveRecoder.pushUrl
            // 不进行直播录制，请注意与音视频服务端录制区分。
            liveTask.serverRecordEnabled = false
            // 设置推音视频流还是纯音频流
            liveTask.liveMode = NERtcLiveStreamTaskInfo.NERtcLiveStreamMode.kNERtcLsModeVideo
            return liveTask
        }

        /**
         * get layout for signal anchor live case
         */
        fun getSignalAnchorStreamLayout(liveRecoder: LiveStreamTaskRecorder): NERtcLiveStreamLayout {
            //设置整体布局
            val layout = NERtcLiveStreamLayout()
            layout.userTranscodingList = ArrayList()
            layout.width = Constants.StreamLayout.SIGNAL_HOST_LIVE_WIDTH //整体布局宽度
            layout.height = Constants.StreamLayout.SIGNAL_HOST_LIVE_HEIGHT //整体布局高度
            layout.backgroundColor = Color.parseColor("#000000") // 整体背景色
            // 设置直播成员布局
            if (liveRecoder.selfUid != 0L) {
                val selfUser = NERtcLiveStreamUserTranscoding()
                selfUser.uid = liveRecoder.selfUid // 用户id
                selfUser.audioPush = true // 推流是否发布user1 的音频
                selfUser.videoPush = true // 推流是否发布user1的视频
                // 如果发布视频，需要设置一下视频布局参数
                // user1 视频的缩放模式， 详情参考NERtcLiveStreamUserTranscoding 的API 文档
                selfUser.adaption =
                    NERtcLiveStreamUserTranscoding.NERtcLiveStreamVideoScaleMode.kNERtcLsModeVideoScaleCropFill
                //独自一个人填充满
                selfUser.width = Constants.StreamLayout.SIGNAL_HOST_LIVE_WIDTH // user1 的视频布局宽度
                selfUser.height = Constants.StreamLayout.SIGNAL_HOST_LIVE_HEIGHT //user1 的视频布局高度
                layout.userTranscodingList.add(selfUser)
            }
            return layout
        }

        /**
         * get layout for two anchor pk case
         */
        fun getPkLiveStreamLayout(liveRecoder: LiveStreamTaskRecorder): NERtcLiveStreamLayout {
            //设置整体布局
            val layout = NERtcLiveStreamLayout()
            layout.userTranscodingList = ArrayList()
            layout.width = Constants.StreamLayout.SIGNAL_HOST_LIVE_WIDTH //整体布局宽度
            layout.height = Constants.StreamLayout.PK_LIVE_HEIGHT //整体布局高度
            layout.backgroundColor = Color.parseColor("#000000") // 整体背景色
            // 设置自己的直播成员布局
            val selfUser = NERtcLiveStreamUserTranscoding()
            selfUser.uid = liveRecoder.selfUid // 用户id
            selfUser.audioPush = true // 推流是否发布user1 的音频
            selfUser.videoPush = true // 推流是否发布user1的视频
            // 如果发布视频，需要设置一下视频布局参数
            // 视频的缩放模式， 详情参考NERtcLiveStreamUserTranscoding 的API 文档
            selfUser.adaption =
                NERtcLiveStreamUserTranscoding.NERtcLiveStreamVideoScaleMode.kNERtcLsModeVideoScaleCropFill
            selfUser.width = Constants.StreamLayout.PK_LIVE_WIDTH // user1 的视频布局宽度
            selfUser.height = Constants.StreamLayout.PK_LIVE_HEIGHT //user1 的视频布局高度
            layout.userTranscodingList.add(selfUser)
            //设置对方的
            liveRecoder.otherAnchorUid?.let {
                val pkUser = NERtcLiveStreamUserTranscoding()
                pkUser.uid = it // 用户id
                pkUser.audioPush = !liveRecoder.muteOther
                pkUser.videoPush = true
                pkUser.adaption =
                    NERtcLiveStreamUserTranscoding.NERtcLiveStreamVideoScaleMode.kNERtcLsModeVideoScaleCropFill
                pkUser.x = Constants.StreamLayout.PK_LIVE_WIDTH
                pkUser.y = 0
                pkUser.width = Constants.StreamLayout.PK_LIVE_WIDTH //
                pkUser.height = Constants.StreamLayout.PK_LIVE_HEIGHT //
                layout.userTranscodingList.add(pkUser)
            }
            return layout
        }

        /**
         * get layout for audience on seat live case
         */
        fun getSeatLiveStreamLayout(liveRecoder: LiveStreamTaskRecorder): NERtcLiveStreamLayout {
            //设置整体布局
            val layout = getSignalAnchorStreamLayout(liveRecoder)
            if (liveRecoder.audienceUid.size > 0) {
                for ((i, uid) in liveRecoder.audienceUid.withIndex()) {
                    val audienceUser = NERtcLiveStreamUserTranscoding()
                    audienceUser.uid = uid // 用户id
                    audienceUser.audioPush = true // 推流是否发布user1 的音频
                    audienceUser.videoPush = true // 推流是否发布user1的视频

                    // user1 视频的缩放模式， 详情参考NERtcLiveStreamUserTranscoding 的API 文档
                    audienceUser.adaption =
                        NERtcLiveStreamUserTranscoding.NERtcLiveStreamVideoScaleMode.kNERtcLsModeVideoScaleCropFill
                    //独自一个人填充满
                    audienceUser.x = Constants.StreamLayout.AUDIENCE_LINKED_LEFT_MARGIN
                    audienceUser.y = (Constants.StreamLayout.AUDIENCE_LINKED_FIRST_TOP_MARGIN
                            + (Constants.StreamLayout.AUDIENCE_LINKED_HEIGHT + Constants.StreamLayout.AUDIENCE_LINKED_BETWEEN_MARGIN) * i)
                    audienceUser.width =
                        Constants.StreamLayout.AUDIENCE_LINKED_WIDTH // user1 的视频布局宽度
                    audienceUser.height =
                        Constants.StreamLayout.AUDIENCE_LINKED_HEIGHT //user1 的视频布局高度
                    layout.userTranscodingList.add(audienceUser)
                }
            }
            return layout
        }
    }
}