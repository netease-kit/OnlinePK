package com.netease.biz_live.yunxin.live.audience.ui.view;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.utils.LinkedSeatsAudienceActionManager;
import com.netease.biz_live.yunxin.live.constant.ApiErrorCode;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAudienceLiveRoomDelegate;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

/**
 * @author sunkeding
 * 等待主播接受连麦申请的横幅
 */
public class WaitAnchorAcceptView extends RelativeLayout {
    private LiveInfo liveInfo;
    private CancelApplySeatClickCallback cancelApplySeatClickCallback;
    private NERTCAudienceLiveRoomDelegate seatCallback;

    public WaitAnchorAcceptView(Context context) {
        super(context);
        init(context);
    }

    public WaitAnchorAcceptView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public WaitAnchorAcceptView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        LayoutInflater.from(context).inflate(R.layout.biz_live_view_wait_anchor_accept, this, true);
        TextView tvCancel=findViewById(R.id.tv_cancel);
        tvCancel.setOnClickListener(v -> {
            tvCancel.setEnabled(false);
            LinkedSeatsAudienceActionManager linkedSeatsAudienceActionManager = LinkedSeatsAudienceActionManager.getInstance((Activity) getContext());
            linkedSeatsAudienceActionManager.setData(seatCallback,liveInfo);
            ALog.d("WaitAnchorAcceptView","cancelSeatApply liveInfo:"+liveInfo.toString());
            linkedSeatsAudienceActionManager.cancelSeatApply(liveInfo.liveCid, ModuleServiceMgr.getInstance().getService(UserCenterService.class).getCurrentUser().accountId, new LiveRoomCallback<Void>() {
                @Override
                public void onSuccess(Void parameter) {
                    super.onSuccess(parameter);
                    setVisibility(GONE);
                    if (cancelApplySeatClickCallback !=null){
                        cancelApplySeatClickCallback.cancel();
                    }
                    tvCancel.setEnabled(true);
                }

                @Override
                public void onError(int code, String msg) {
                    ToastUtils.showShort(msg);
                    if(ApiErrorCode.DONT_APPLY_SEAT==code){
                        setVisibility(GONE);
                        if (cancelApplySeatClickCallback !=null){
                            cancelApplySeatClickCallback.cancel();
                        }
                    }else {
                        setVisibility(VISIBLE);
                    }
                    tvCancel.setEnabled(true);
                }
            });
        });
    }

    public void setLiveInfo(LiveInfo liveInfo) {
       this.liveInfo=liveInfo;
    }

    public void setCancelApplySeatClickCallback(CancelApplySeatClickCallback cancelApplySeatClickCallback) {
        this.cancelApplySeatClickCallback = cancelApplySeatClickCallback;
    }

    public void setAudienceLiveRoomDelegate(NERTCAudienceLiveRoomDelegate seatCallback) {
        this.seatCallback=seatCallback;
    }

    public interface CancelApplySeatClickCallback {
        void cancel();
    }
}
