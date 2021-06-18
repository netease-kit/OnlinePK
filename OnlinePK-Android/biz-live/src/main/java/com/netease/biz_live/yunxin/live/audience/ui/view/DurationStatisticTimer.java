/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.audience.ui.view;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;

import androidx.annotation.Nullable;

import com.blankj.utilcode.util.SPUtils;
import com.netease.yunxin.kit.alog.ALog;

import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

/**
 * @author sunkeding
 * 时长统计
 */
public class DurationStatisticTimer extends androidx.appcompat.widget.AppCompatTextView {
    private static final String TAG = "DurationStatisticTimer";
    private TimerTask timerTask;
    private Timer timer;
    private static final int PERIOD = 1000;
    private static final int DELAY = 0;
    private long costSeconds = 0L;
    private final Handler uiHandler = new Handler(Looper.getMainLooper());
    private final StringBuilder stringBuilder = new StringBuilder();

    public DurationStatisticTimer(Context context) {
        super(context);
    }

    public DurationStatisticTimer(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public DurationStatisticTimer(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void start() {
        costSeconds = Math.round((System.currentTimeMillis() - DurationUtil.getBeginTimeStamp())/1000.0);
        if (timerTask == null) {
            timerTask = new TimerTask() {
                @Override
                public void run() {
                    try {
                        ALog.d(TAG,"sceond:" + costSeconds);
                        uiHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                setText(String.format(Locale.US, "连麦中，通话时长:%s", getTime(costSeconds)));
                            }
                        });
                        costSeconds++;
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
            };
        }
        if (timer == null) {
            timer = new Timer();
        }
        timer.schedule(timerTask, DELAY, PERIOD);
    }


    public void stop() {
        if (timerTask != null) {
            timerTask.cancel();
            timerTask=null;
        }
        if (timer != null) {
            timer.cancel();
            timer.purge();
            timer=null;
        }
    }

    public String getTime(long time) {
        stringBuilder.setLength(0);
        if (time / 3600 > 0) {
            stringBuilder.append(time / 3600).append("小时");
        }
        if (time % 3600 / 60 > 0) {
            stringBuilder.append(time % 3600 / 60).append("分");
        }
        if (time % 3600 % 60 > 0) {
            stringBuilder.append(time % 3600 % 60).append("秒");
        }
        return stringBuilder.toString();
    }

    public static class DurationUtil {
        private static final String SP_KEY = "begin_timestamp";

        /**
         * 设置连麦开始时间
         */
        public static void setBeginTimeStamp(long beginTimeStamp) {
            SPUtils.getInstance().put(SP_KEY, beginTimeStamp);
        }

        public static long getBeginTimeStamp() {
            return SPUtils.getInstance().getLong(SP_KEY, 0L);
        }

        public static void reset() {
            setBeginTimeStamp(0L);
        }
    }
}
