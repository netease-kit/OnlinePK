/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.dialog.adapter;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;

import com.netease.biz_live.yunxin.live.dialog.fragment.AudienceListFragment;

import java.util.ArrayList;
import java.util.List;

public class AudiencePageAdapter extends FragmentPagerAdapter {

    private String roomId;

    private static final int SIZE = 3;

    public AudiencePageAdapter(@NonNull FragmentManager fm,@NonNull String roomId) {
        super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
        this.roomId = roomId;
        initFragment();
    }

    @NonNull
    @Override
    public Fragment getItem(int position) {
        Bundle bundle = new Bundle();
        bundle.putString(AudienceListFragment.ROOM_ID,roomId);
        switch (position){
            case 0:
                bundle.putInt(AudienceListFragment.TYPE,AudienceListFragment.TYPE_INVITED);
                break;
            case 1:
                bundle.putInt(AudienceListFragment.TYPE,AudienceListFragment.TYPE_APPLY);
                break;
            case 2:
                bundle.putInt(AudienceListFragment.TYPE,AudienceListFragment.TYPE_MANAGER);
                break;
        }
        cacheFragment.get(position).setArguments(bundle);
        return cacheFragment.get(position);
    }

    @Override
    public int getCount() {
        return SIZE;
    }

    private final List<AudienceListFragment> cacheFragment = new ArrayList<>(SIZE);

    private void initFragment(){
        for(int i = 0;i< SIZE;i++) {
            cacheFragment.add(new AudienceListFragment());
        }
    }
}
