package com.netease.biz_live.yunxin.live.audience.utils;

import android.app.Activity;
import android.graphics.PointF;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PkStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;
import com.netease.biz_live.yunxin.live.constant.LiveStreamParams;
import com.netease.biz_live.yunxin.live.constant.LiveStatus;
import com.netease.biz_live.yunxin.live.constant.LiveTimeDef;
import com.netease.biz_live.yunxin.live.constant.LiveType;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.model.response.AnchorMemberInfo;
import com.netease.biz_live.yunxin.live.model.response.AnchorQueryInfo;
import com.netease.biz_live.yunxin.live.model.response.PkLiveContributeTotal;
import com.netease.biz_live.yunxin.live.model.response.PkRecord;
import com.netease.biz_live.yunxin.live.network.LiveInteraction;
import com.netease.biz_live.yunxin.live.ui.widget.PKControlView;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.utils.SpUtils;

import java.util.Arrays;
import java.util.List;

import io.reactivex.Single;
import io.reactivex.observers.ResourceSingleObserver;

/**
 * 观众端PK管理
 */
public class AudiencePKControl {
    private static final String TAG="AudiencePKControl";
    /**
     * 直播播放View
     */
    private TextureView videoView;
    /**
     * pk 状态整体控制
     */
    private PKControlView pkControlView;

    /**
     * pk 阶段倒计时
     */
    private PKControlView.WrapperCountDownTimer countDownTimer;
    private Activity activity;

    public void init(Activity activity,TextureView videoView,View infoContentView){
        this.activity=activity;
        this.videoView=videoView;
        pkControlView = infoContentView.findViewById(R.id.pkv_control);
    }

    public void onAnchorCoinChanged(AnchorCoinChangedAttachment attachment){
        if (pkControlView.getVisibility() == View.VISIBLE) {
            pkControlView.updateScore(attachment.pkCoinCount, attachment.otherPkCoinCount);
            pkControlView.updateRanking(attachment.rewardList, attachment.otherRewardList);
        }
    }

    public void onPKStatusChanged(PkStatusAttachment pkStatus) {
        if (countDownTimer != null) {
            countDownTimer.stop();
        }
        if (pkStatus.isStartState()) {
            // pk 状态下view渲染
            pkControlView.setVisibility(View.VISIBLE);
            // 重置pk控制view
            pkControlView.reset();
            // 设置pk 主播昵称/头像
            pkControlView.updatePkAnchorInfo(pkStatus.otherAnchorNickname, pkStatus.otherAnchorAvatar);
            // 调整视频播放比例
            adjustVideoSizeForPk(true);
            // 定时器倒计时
            long leftTime = pkStatus.getLeftTime(LiveTimeDef.TOTAL_TIME_PK, 0);
            countDownTimer = pkControlView.createCountDownTimer(LiveTimeDef.TYPE_PK, leftTime);
            countDownTimer.start();
        } else {
            pkControlView.handleResultFlag(true, pkStatus.anchorWin);
        }
    }
    public void adjustVideoSizeForPk(boolean isPrepared) {
        int width = SpUtils.getScreenWidth(activity);
        int height = (int) (width / LiveStreamParams.WH_RATIO_PK);

        float x = width / 2f;
        float y = StatusBarConfig.getStatusBarHeight(activity) + SpUtils.dp2pix(activity, 64) + height / 2f;

        PointF pivot = new PointF(x, y);
        ALog.e("=====>", "pk video view center point is " + pivot);
        if (isPrepared) {
            PlayerVideoSizeUtils.adjustForPreparePk(videoView, pivot);
        } else {
            PlayerVideoSizeUtils.adjustViewSizePosition(videoView, true, pivot);
        }
    }
    public void onPunishmentStatusChanged(PunishmentStatusAttachment punishmentStatus) {
        if (countDownTimer != null) {
            countDownTimer.stop();
        }
        if (punishmentStatus.isStartState()) {
            // 定时器倒计时
            long leftTime = punishmentStatus.getLeftTime(LiveTimeDef.TOTAL_TIME_PUNISHMENT, 0);
            if (punishmentStatus.anchorWin != 0) {
                countDownTimer = pkControlView.createCountDownTimer(LiveTimeDef.TYPE_PUNISHMENT, leftTime);
                countDownTimer.start();
            }
        } else {
            pkControlView.setVisibility(View.INVISIBLE);
        }
    }

    public void showPkMaskUI(boolean canRender, AnchorQueryInfo anchorQueryInfo, LiveInfo liveInfo) {
        // 停止倒计时
        if (countDownTimer != null) {
            countDownTimer.stop();
        }

        PkRecord record = anchorQueryInfo.pkRecord;
        pkControlView.setVisibility(View.VISIBLE);
        // 更新比分
        if (record.inviter.equals(liveInfo.accountId)) {
            pkControlView.updateScore(record.inviterRewards, record.inviteeRewards);
        } else {
            pkControlView.updateScore(record.inviteeRewards, record.inviterRewards);
        }

        // pk 场景下主播成员列表数为2，分别为当前主播以及pk方主播，从列表中取出pk 主播数据
        AnchorMemberInfo temp = anchorQueryInfo.members.get(0);
        AnchorMemberInfo temp1 = anchorQueryInfo.members.get(1);
        AnchorMemberInfo pkMemberInfo = liveInfo.accountId.equals(temp.accountId) ? temp1 : temp;
        // 更新pk 主播头像和昵称
        pkControlView.updatePkAnchorInfo(pkMemberInfo.nickname, pkMemberInfo.avatar);
        // 两次网络请求对应主播的贡献排行
        Single<PkLiveContributeTotal> anchorSource =
                LiveInteraction.queryPkLiveContributeTotal(liveInfo.accountId, liveInfo.liveCid, LiveType.PK_LIVING);
        Single<PkLiveContributeTotal> otherAnchorSource =
                LiveInteraction.queryPkLiveContributeTotal(pkMemberInfo.accountId, pkMemberInfo.liveCid, LiveType.PK_LIVING);
        // 合并网络请求
        Single.zip(anchorSource, otherAnchorSource,
                (pkLiveContributeTotal, pkLiveContributeTotal2) -> Arrays.asList(pkLiveContributeTotal, pkLiveContributeTotal2))
                .subscribe(new ResourceSingleObserver<List<PkLiveContributeTotal>>() {
                    @Override
                    public void onSuccess(@NonNull List<PkLiveContributeTotal> pkLiveContributeTotals) {
                        if (!canRender) {
                            return;
                        }
                        // 更新排行榜数据
                        PkLiveContributeTotal contributeTotal = pkLiveContributeTotals.get(0);
                        PkLiveContributeTotal contributeTotal1 = pkLiveContributeTotals.get(1);
                        if (liveInfo.accountId.equals(contributeTotal.accountId)) {
                            pkControlView.updateRanking(contributeTotal.getAudienceInfoList(), contributeTotal1.getAudienceInfoList());
                        } else {
                            pkControlView.updateRanking(contributeTotal1.getAudienceInfoList(), contributeTotal.getAudienceInfoList());
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        ALog.e(TAG, "获取贡献榜信息失败");
                    }
                });

        // 惩罚阶段 展示 pk 结果，并开始惩罚倒计时
        if (record.status == LiveStatus.PK_PUNISHMENT) {
            int pkResult;
            if(record.inviterRewards == record.inviteeRewards){
                pkResult = 0;
            }else if(record.inviter.equals(liveInfo.accountId)){//本方是邀请者
                pkResult = record.inviterRewards > record.inviteeRewards?1:-1;
            }else {
                pkResult = record.inviterRewards < record.inviteeRewards?1:-1;
            }
            pkControlView.handleResultFlag(true, pkResult);
            if(pkResult != 0) {
                long leftTime = TimeUtils.getLeftTime(LiveTimeDef.TOTAL_TIME_PUNISHMENT, record.currentTime, record.punishmentStartTime, 0);
                countDownTimer = pkControlView.createCountDownTimer(LiveTimeDef.TYPE_PUNISHMENT, leftTime);
                countDownTimer.start();
            }
        } else { // pk 进行中开始pk 倒计时
            pkControlView.handleResultFlag(false, 0);
            long leftTime = TimeUtils.getLeftTime(LiveTimeDef.TOTAL_TIME_PK, record.currentTime, record.pkStartTime, 0);
            countDownTimer = pkControlView.createCountDownTimer(LiveTimeDef.TYPE_PK,leftTime);
            countDownTimer.start();
        }
    }

    public boolean isPk(){
        return pkControlView.getVisibility() == View.VISIBLE;
    }

    public void release() {
        // pk 状态隐藏
        if (countDownTimer != null) {
            countDownTimer.stop();
        }
        if (pkControlView!=null){
            pkControlView.setVisibility(View.INVISIBLE);
        }
    }
}
