/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.nertc.demo;

import android.app.Application;

import com.netease.biz_live.yunxin.live.LiveApplicationLifecycle;
import com.netease.biz_live.yunxin.live.LiveService;
import com.netease.biz_live.yunxin.live.LiveServiceImpl;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.alog.BasicInfo;
import com.netease.yunxin.nertc.demo.basic.BuildConfig;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserCenterServiceImpl;
import com.netease.yunxin.nertc.module.base.ApplicationLifecycleMgr;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;
import com.netease.yunxin.nertc.module.base.sdk.NESdkBase;

public class DemoApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        ALog.init(this, ALog.LEVEL_ALL);
        ALog.logFirst(new BasicInfo.Builder()
                .name(getString(R.string.app_name))
                .version("v"+ com.netease.yunxin.nertc.demo.BuildConfig.VERSION_NAME)
                .gitHashCode(com.netease.yunxin.nertc.demo.BuildConfig.GIT_COMMIT_HASH)
                .deviceId(this)
                .baseUrl(BuildConfig.BASE_URL)
                .packageName(this)
                .nertcVersion(com.netease.yunxin.nertc.demo.BuildConfig.VERSION_NERTC)
                .imVersion(com.netease.yunxin.nertc.demo.BuildConfig.VERSION_IM)
                .build());
        // 配置网络基础 url 以及 debug 开关
        NetworkClient.getInstance()
                .configBaseUrl(BuildConfig.BASE_URL)
                .appKey(BuildConfig.APP_KEY)
                .configDebuggable(true);
        // 初始化相关sdk
        NESdkBase.getInstance()
                .initContext(this)
                // 初始化 IM sdk
                //此处仅设置 AppKey，其他设置请自行参看信令文档设置 https://dev.yunxin.163.com/docs/product/信令/SDK开发集成/Android开发集成/初始化
                .initIM(BuildConfig.APP_KEY, null)
                //初始化美颜(相芯)
                .initFaceunity();

        // 各个module初始化逻辑
        ApplicationLifecycleMgr.getInstance()
                .registerLifecycle(new LiveApplicationLifecycle())
                .notifyOnCreate(this);

        // 模块方法实例注册
        ModuleServiceMgr.getInstance()
                // 用户模块
                .registerService(UserCenterService.class, getApplicationContext(), new UserCenterServiceImpl())
                // 直播模块
                .registerService(LiveService.class, getApplicationContext(), new LiveServiceImpl());
    }
}
