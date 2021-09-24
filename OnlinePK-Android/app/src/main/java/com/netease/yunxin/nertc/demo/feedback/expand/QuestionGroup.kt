/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.feedback.expand

import java.util.*

/**
 * Created by luc on 2020/11/17.
 */
class QuestionGroup(val title: String, items: List<QuestionItem>?) {
    val items: List<QuestionItem>

    init {
        this.items = ArrayList(items)
    }
}