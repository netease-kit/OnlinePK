/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.dialog.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.dialog.adapter.AudienceListAdapter;
import com.netease.biz_live.yunxin.live.model.response.SeatsResponse;
import com.netease.biz_live.yunxin.live.network.SeatsManagerInteraction;
import com.netease.yunxin.android.lib.network.common.BaseResponse;

import io.reactivex.observers.ResourceSingleObserver;

public class AudienceListFragment extends Fragment {

    public static final int TYPE_INVITED = 2;

    public static final int TYPE_APPLY = 1;

    public static final int TYPE_MANAGER = 3;

    public static final String ROOM_ID = "room_id";

    public static final String TYPE = "audience_type";

    private int type;

    private String roomId;

    private AudienceListAdapter audienceListAdapter;

    public AudienceListFragment(){
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_audience_list_layout, container, false);
        initView(rootView);
        return rootView;
    }

    private void initView(View view){
        if(getArguments() != null){
            Bundle bundle = getArguments();
            type = bundle.getInt(TYPE);
            roomId = bundle.getString(ROOM_ID);
        }
        RecyclerView rvAudienceList = view.findViewById(R.id.rcv_audience);
        rvAudienceList.setLayoutManager(new LinearLayoutManager(getContext()));
        audienceListAdapter = new AudienceListAdapter(getActivity(), type);
        rvAudienceList.setAdapter(audienceListAdapter);
    }

    @Override
    public void onResume() {
        super.onResume();
        SeatsManagerInteraction.getAudienceList(roomId,type).subscribe(new ResourceSingleObserver<BaseResponse<SeatsResponse>>() {
            @Override
            public void onSuccess(@io.reactivex.annotations.NonNull BaseResponse<SeatsResponse> response) {
                if(audienceListAdapter != null && response.data != null){
                    audienceListAdapter.setData(response.data.seatList);
                }
            }

            @Override
            public void onError(@io.reactivex.annotations.NonNull Throwable e) {

            }
        });
    }
}
