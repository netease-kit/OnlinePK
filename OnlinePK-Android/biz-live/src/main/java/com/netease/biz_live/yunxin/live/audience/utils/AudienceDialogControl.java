package com.netease.biz_live.yunxin.live.audience.utils;

import android.app.Activity;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.dialog.ChoiceDialog;
import com.netease.biz_live.yunxin.live.dialog.TipsDialog;

/**
 * @author sunkeding
 * 观众端弹窗管理
 */
public class AudienceDialogControl {
    private ChoiceDialog anchorInviteDialog;
    private TipsDialog tipsDialog;
    /**
     * 主播拒绝了你的连麦申请
     */
    public void showAnchorRejectDialog(Activity activity) {
        if (tipsDialog==null){
            tipsDialog = new TipsDialog(activity);
        }
        tipsDialog.setCancelable(false);
        tipsDialog.setContent(activity.getString(R.string.biz_live_anchor_reject_link_seats_apply));
        tipsDialog.setPositive(activity.getString(R.string.biz_live_i_know), v -> {
            tipsDialog.dismiss();
        });
        if (!tipsDialog.isShowing()) {
            tipsDialog.show();
        }
    }


    /**
     * 主播邀请你上麦
     */
    public void showAnchorInviteDialog(Activity activity, AudienceDialogControl.JoinSeatsListener joinSeatsListener) {
        if (anchorInviteDialog==null){
            anchorInviteDialog = new ChoiceDialog(activity);
        }
        anchorInviteDialog.setCancelable(false);
        anchorInviteDialog.setTitle(activity.getString(R.string.biz_live_invite_join_seats));
        anchorInviteDialog.setContent(activity.getString(R.string.biz_live_anchor_invite_audience_join_seats));
        anchorInviteDialog.setNegative(activity.getString(R.string.biz_live_reject), v -> {
            if (joinSeatsListener != null) {
                joinSeatsListener.rejectInvite();
            }
            anchorInviteDialog.dismiss();
        });
        anchorInviteDialog.setPositive(activity.getString(R.string.biz_live_join_seats), v -> {
            if (joinSeatsListener != null) {
                joinSeatsListener.acceptInvite();
            }
            anchorInviteDialog.dismiss();
        });
        if (!anchorInviteDialog.isShowing()) {
            anchorInviteDialog.show();
        }
        if (joinSeatsListener != null) {
            this.setJoinSeatsListener(joinSeatsListener);
        }
    }

    public void dismissAnchorInviteDialog(){
        if (anchorInviteDialog!=null&&anchorInviteDialog.isShowing()){
            anchorInviteDialog.dismiss();
        }
    }

    public void setJoinSeatsListener(JoinSeatsListener joinSeatsListener) {
        this.joinSeatsListener = joinSeatsListener;
    }

    private JoinSeatsListener joinSeatsListener;

    public interface JoinSeatsListener {
        void acceptInvite();

        void rejectInvite();
    }
}
