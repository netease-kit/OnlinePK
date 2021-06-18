/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom.model;

import java.util.HashSet;
import java.util.List;

/**
 * 推流recorder
 */
public class LiveStreamTaskRecorder {
    /**
     * 单主播直播
     */
    public static final int TYPE_SINGLE = 0;

    /**
     * PK直播
     */
    public static final int TYPE_PK = 1;

    /**
     * 连麦直播
     */
    public static final int TYPE_SEATS = 2;

    public String pushUlr;
    public long anchorUid;

    /**
     * Pk主播的Uid
     */
    public long pkAnchorUid;

    /**
     * 连麦观众的uid
     */
    public HashSet<Long> audienceUids;

    public String taskId;


    /**
     * 直播type，默认0
     */
    public int type;

    public LiveStreamTaskRecorder(String pushUlr, long anchorUid) {
        this.pushUlr = pushUlr;
        this.anchorUid = anchorUid;
        audienceUids = new HashSet<>();
        taskId = String.valueOf(Math.abs(pushUlr.hashCode()));
    }

    public LiveStreamTaskRecorder(String pushUlr, int liveType, long anchorUid, long pkAnchorUid) {
        this(pushUlr,anchorUid);
        this.type = liveType;
        this.pkAnchorUid = pkAnchorUid;
    }

    public boolean isPk(){
        return type == TYPE_PK;
    }

    /**
     * 是否观众上麦
     * @return
     */
    public boolean isLinked() {
        return type == TYPE_SEATS;
    }

    public void addUser(long uid) {
        type = TYPE_SEATS;
        audienceUids.add(uid);
    }

    public void fetchUsers(List<Long> uids) {
        audienceUids.clear();
        if (uids != null) {
            audienceUids.addAll(uids);
        }
    }

    public void removeUser(long uid) {
        audienceUids.remove(uid);
        if (audienceUids.size() == 0) {
            type = TYPE_SINGLE;
        }
    }

    @Override
    public String toString() {
        return "LiveStreamTaskRecorder{" +
                "pushUlr='" + pushUlr + '\'' +
                ", anchorUid=" + anchorUid +
                ", pkAnchorUid=" + pkAnchorUid +
                ", audienceUids=" + audienceUids +
                ", taskId='" + taskId + '\'' +
                ", type=" + type +
                '}';
    }
}
