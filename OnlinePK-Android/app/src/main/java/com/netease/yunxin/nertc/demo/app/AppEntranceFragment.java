/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.nertc.demo.app;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_live.yunxin.live.LiveService;
import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseFragment;
import com.netease.yunxin.nertc.demo.list.FunctionAdapter;
import com.netease.yunxin.nertc.demo.list.FunctionItem;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.Arrays;

public class AppEntranceFragment extends BaseFragment {
    public AppEntranceFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    private void initView(View rootView) {
        // 功能列表初始化
        RecyclerView rvFunctionList = rootView.findViewById(R.id.rv_function_list);
        rvFunctionList.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        rvFunctionList.setAdapter(new FunctionAdapter(getContext(), Arrays.asList(
                // 每个业务功能入口均在此处生成 item
                new FunctionItem(R.drawable.icon_pk_live, "PK 直播", "从单人直播到主播间PK，观众连麦多种玩法",
                        () -> {
                            LiveService liveService = ModuleServiceMgr.getInstance().getService(LiveService.class);
                            liveService.launchPkLive(getContext(), "PK直播");
                        }),
                new FunctionItem(R.drawable.icon_multi_micro, "多人连麦直播", "支持1V4主播和观众的视频互动",
                        () -> {
                            LiveService liveService = ModuleServiceMgr.getInstance().getService(LiveService.class);
                            liveService.launchPkLive(getContext(), "多人连麦直播");
                        })
        )));
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_app_entrance, container, false);
        initView(rootView);
        paddingStatusBarHeight(rootView);
        return rootView;
    }
}