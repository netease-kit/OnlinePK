/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.list

class FunctionItem {
    var type: Int = FunctionAdapter.Companion.TYPE_VIEW_CONTENT
    val iconResId: Int
    val nameStr: String
    val descriptionStr: String?
    val action: Runnable?

    constructor(type: Int, nameStr: String, iconResId: Int) {
        this.type = type
        this.nameStr = nameStr
        descriptionStr = null
        this.iconResId = iconResId
        action = null
    }

    constructor(iconResId: Int, nameStr: String, descriptionStr: String?, action: Runnable?) {
        this.iconResId = iconResId
        this.nameStr = nameStr
        this.descriptionStr = descriptionStr
        this.action = action
    }
}