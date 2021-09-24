/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.model.response

import com.netease.yunxin.lib_live_room_service.bean.LiveInfo


/**
 * 直播主页面列表返回值
 */
class LiveListResponse {
    var endRow //int	每页大小
            = 0
    var hasNextPage //boolean	是否有下一页
            = false
    var hasPreviousPage //boolean	是否上一页
            = false
    var isLastPage //boolean	最后一页
            = false
    var isFirstPage //boolean	第一页
            = false
    var list //直播房间列表
            : MutableList<LiveInfo>? = null
}