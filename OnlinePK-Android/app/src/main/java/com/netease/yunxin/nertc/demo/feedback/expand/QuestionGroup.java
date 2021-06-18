/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.nertc.demo.feedback.expand;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by luc on 2020/11/17.
 */
public class QuestionGroup {
    public final String title;
    public final List<QuestionItem> items;

    public QuestionGroup(String title, List<QuestionItem> items) {
        this.title = title;
        this.items = new ArrayList<>(items);
    }
}
