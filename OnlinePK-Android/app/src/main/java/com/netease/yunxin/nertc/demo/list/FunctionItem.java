/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.nertc.demo.list;

public class FunctionItem {
    public int type = FunctionAdapter.TYPE_VIEW_CONTENT;

    public final int iconResId;

    public final String nameStr;

    public final String descriptionStr;

    public final Runnable action;

    public FunctionItem(int type, String nameStr,int iconResId) {
        this.type = type;
        this.nameStr = nameStr;
        this.descriptionStr = null;
        this.iconResId = iconResId;
        this.action = null;
    }

    public FunctionItem(int iconResId, String nameStr,String descriptionStr, Runnable action) {
        this.iconResId = iconResId;
        this.nameStr = nameStr;
        this.descriptionStr = descriptionStr;
        this.action = action;
    }
}
