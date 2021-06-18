/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.ui.widget;

import android.content.Context;
import android.graphics.Rect;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.ConvertUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.liveroom.AnchorSeatManager;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAudienceLiveRoom;
import com.netease.biz_live.yunxin.live.liveroom.NERTCLiveRoom;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author sunkeding
 * 连麦观众列表,主播端、观众端使用交互略有不同
 */
public class LinkSeatsAudienceRecycleView extends RecyclerView {
    private SeatsAdapter mAdapter;
    private ArrayList<SeatMemberInfo> list = new ArrayList<>();
    private static final int dp8 = ConvertUtils.dp2px(8f);

    public LinkSeatsAudienceRecycleView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public LinkSeatsAudienceRecycleView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public LinkSeatsAudienceRecycleView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        setItemAnimator(null);
        mAdapter = new SeatsAdapter(context, list);
        setLayoutManager(new LinearLayoutManager(context));
        addItemDecoration(new ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull State state) {
                super.getItemOffsets(outRect, view, parent, state);
                int position = parent.getChildAdapterPosition(view);
                if (position == 0) {
                    outRect.top = 0;
                } else {
                    outRect.top = dp8;
                }
            }
        });
        setAdapter(mAdapter);
    }

    public void setUseScene(int useScene) {
        mAdapter.setUseScene(useScene);
    }

    public void setLiveInfo(LiveInfo liveInfo) {
        mAdapter.setLiveInfo(liveInfo);
    }

    public void appendItem(SeatMemberInfo member) {
        mAdapter.appendItem(member);
    }

    public void appendItem(int targetIndex, SeatMemberInfo member) {
        mAdapter.appendItem(targetIndex, member);
    }

    public void appendItems(List<SeatMemberInfo> appendList) {
        mAdapter.appendItems(appendList);
    }

    public void remove(int index) {
        mAdapter.remove(index);
    }

    public void remove(SeatMemberInfo member) {
        mAdapter.remove(member);
    }

    public boolean haveMemberInSeats() {
        return !list.isEmpty();
    }

    public boolean contains(String accountId) {
        for (SeatMemberInfo member : list) {
            if (!TextUtils.isEmpty(accountId) && accountId.equals(member.accountId)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 获取麦上观众
     *
     * @return
     */
    public List<SeatMemberInfo> getMemberList() {
        return list;
    }

    public void updateItem(int index, SeatMemberInfo member) {
        mAdapter.updateItem(index, member);
    }

    public void updateItem(SeatMemberInfo member) {
        mAdapter.updateItem(member);
    }

    public static class SeatsAdapter extends Adapter<ViewHolder> {
        private Context context;
        private ArrayList<SeatMemberInfo> list;
        /**
         * 使用场景，分为主播端，观众端
         */
        private int useScene = UseScene.UNKNOWN;
        /**
         * 直播间信息
         */
        private LiveInfo liveInfo;

        public void setUseScene(int useScene) {
            this.useScene = useScene;
        }

        public SeatsAdapter(Context context, ArrayList<SeatMemberInfo> list) {
            this.context = context;
            this.list = list;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SeatsViewHolder(LayoutInflater.from(context).inflate(R.layout.biz_live_single_seats_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            SeatMemberInfo member = list.get(position);
            if (member == null) {
                return;
            }
            SeatsViewHolder seatsViewHolder = (SeatsViewHolder) holder;
            seatsViewHolder.bindData(member, useScene);
            seatsViewHolder.setCloseCallback(seatsInfo1 -> {
                if (UseScene.UNKNOWN == useScene) {
                    return;
                }
                if (UseScene.ANCHOR == useScene) {
                    NERTCLiveRoom.sharedInstance(true).getService(AnchorSeatManager.class).kickSeat(member.accountId, new LiveRoomCallback<Void>() {
                        @Override
                        protected void onSuccess() {
                            super.onSuccess();
                            remove(seatsInfo1);
                        }

                        @Override
                        public void onError(int code, String msg) {
                            ToastUtils.showShort(msg);
                        }
                    });
                } else if (UseScene.AUDIENCE == useScene) {
                    NERTCAudienceLiveRoom.sharedInstance().leaveSeat(liveInfo.liveCid, new LiveRoomCallback<Void>() {
                        @Override
                        public void onSuccess(Void parameter) {
                            super.onSuccess(parameter);
                            remove(seatsInfo1);
                        }

                        @Override
                        public void onError(int code, String msg) {
                            ToastUtils.showShort(msg);
                        }
                    });
                }
            });
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        public void appendItem(SeatMemberInfo member) {
            if (member == null) {
                return;
            }
            if (list.contains(member)){
                return;
            }
            list.add(member);
            notifyItemInserted(list.size() - 1);
        }

        public void appendItem(int targetIndex, SeatMemberInfo member) {
            if (member == null || targetIndex < 0) {
                return;
            }
            if (list.contains(member)){
                return;
            }
            list.add(targetIndex, member);
            notifyItemRangeInserted(targetIndex,list.size()-targetIndex);
        }

        public void appendItems(List<SeatMemberInfo> appendList) {
            if (appendList == null || appendList.isEmpty()) {
                return;
            }
            int positionStart = list.size();
            int appendCount=0;
            for (SeatMemberInfo member : appendList) {
                if (!list.contains(member)){
                    list.add(member);
                    appendCount++;
                }
            }
            if (appendCount>0){
                notifyItemRangeInserted(positionStart,appendCount);
            }
        }

        public void remove(int index) {
            list.remove(index);
            notifyItemRemoved(index);
        }

        public void remove(SeatMemberInfo member) {
            if (member == null) {
                return;
            }
            int removeIndex = list.indexOf(member);
            if (removeIndex >= 0) {
                list.remove(removeIndex);
                notifyItemRemoved(removeIndex);
            }
        }

        public void updateItem(int index, SeatMemberInfo member) {
            list.set(index, member);
            notifyItemChanged(index);
        }

        public void updateItem(SeatMemberInfo member) {
            int targetIndex=list.indexOf(member);
            if (targetIndex >= 0) {
                updateItem(targetIndex, member);
            }
        }

        public void setLiveInfo(LiveInfo liveInfo) {
            this.liveInfo = liveInfo;
        }

    }

    private static class SeatsViewHolder extends ViewHolder {
        private SingleAudienceSeatsView seatsView;
        private CloseCallback closeCallback;

        public SeatsViewHolder(@NonNull View itemView) {
            super(itemView);
            seatsView = itemView.findViewById(R.id.audience_seats_view);
        }

        public void bindData(SeatMemberInfo member, int useScene) {
            seatsView.initLiveRoom(null, UseScene.ANCHOR == useScene);
            seatsView.setData(member);
            seatsView.setCloseSeatCallback(seatsInfo1 -> closeCallback.closeSeat(seatsInfo1));
        }

        public void setCloseCallback(CloseCallback closeCallback) {
            this.closeCallback = closeCallback;
        }

        public interface CloseCallback {
            void closeSeat(SeatMemberInfo member);
        }
    }

    public interface UseScene {
        int UNKNOWN = -1;
        int ANCHOR = 0;
        int AUDIENCE = 1;
    }


}
