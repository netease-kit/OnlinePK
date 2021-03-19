package com.netease.yunxin.nertc.demo;

import android.app.Application;

import com.netease.biz_live.yunxin.live.LiveApplicationLifecycle;
import com.netease.biz_live.yunxin.live.LiveService;
import com.netease.biz_live.yunxin.live.LiveServiceImpl;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
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
