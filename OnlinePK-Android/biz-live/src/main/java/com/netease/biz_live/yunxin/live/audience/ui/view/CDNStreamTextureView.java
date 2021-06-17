package com.netease.biz_live.yunxin.live.audience.ui.view;

import android.content.Context;
import android.graphics.Matrix;
import android.graphics.PointF;
import android.util.AttributeSet;
import android.view.TextureView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.blankj.utilcode.util.ScreenUtils;
import com.netease.biz_live.yunxin.live.audience.utils.PlayerControl;
import com.netease.biz_live.yunxin.live.audience.utils.PlayerVideoSizeUtils;
import com.netease.biz_live.yunxin.live.constant.LiveStreamParams;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.utils.SpUtils;

/**
 * 播放直播间的CDN流
 */
public class CDNStreamTextureView extends TextureView {
    private static final String TAG = "MyTextureView";
    /**
     * 播放器控制，通过注册 TextureView 实现，控制播放器的
     */
    private PlayerControl playerControl;
    private BaseActivity activity;
    private boolean canRender;
    /**
     * 是否正在连麦
     */
    private boolean isLinkingSeats = false;

    public CDNStreamTextureView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public CDNStreamTextureView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public CDNStreamTextureView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        activity = (BaseActivity) context;
    }

    public void setUp(boolean canRender) {
        this.canRender = canRender;
    }

    public void reset() {
        getPlayerControl().reset();
    }

    public void prepare(LiveInfo liveInfo) {
        getPlayerControl().prepareToPlay(liveInfo.liveConfig.rtmpPullUrl, this);
    }

    public void setLinkingSeats(boolean linkingSeats) {
        this.isLinkingSeats = linkingSeats;
        this.post(() -> {
            if (isLinkingSeats){
                adjustVideoSizeForLinkSeats();
            }else {
                adjustVideoSizeForNormal();
            }
        });
    }

    public void release() {
        if (playerControl != null) {
            playerControl.release();
            playerControl = null;
        }
    }

    /**
     * 播放器控制回调
     */
    private final PlayerControl.PlayerNotify playerNotify = new PlayerControl.PlayerNotify() {
        @Override
        public void onPreparing() {
            ALog.e(TAG, "player, preparing");

        }

        @Override
        public void onPlaying() {
            changeErrorState(false, AudienceErrorStateView.TYPE_ERROR);
            ALog.e(TAG, "player, playing");
        }

        @Override
        public void onError() {
            changeErrorState(true, AudienceErrorStateView.TYPE_ERROR);
            ALog.e(TAG, "player, error");
        }

        @Override
        public void onVideoSizeChanged(int width, int height) {
            if (height == LiveStreamParams.PK_LIVE_HEIGHT) {
                adjustVideoSizeForPk(false);
            } else if (isLinkingSeats){
                adjustVideoSizeForLinkSeats();
            }else {
                adjustVideoSizeForNormal();
            }
            ALog.e(TAG, "video size changed, width is " + width + ", height is " + height);
        }
    };

    private void adjustVideoSizeForLinkSeats() {
        // 宽满屏，VideoView按视频的宽高比同比例放大，VideoView在屏幕居中展示
        // 目标视频比例
        float videoWidth = LiveStreamParams.SIGNAL_HOST_LIVE_WIDTH;
        float videoHeight = LiveStreamParams.SIGNAL_HOST_LIVE_HEIGHT;
        int viewWidth=ScreenUtils.getScreenWidth();
        int viewHeight=ScreenUtils.getScreenHeight();
        // 填充满 720*1280区域
        Matrix matrix = new Matrix();
        // 平移 使 view 中心和 video 中心一致
        matrix.preTranslate((viewWidth - videoWidth) / 2f, (viewHeight - videoHeight) / 2f);
        //缩放 view 至原视频大小
        matrix.preScale(videoWidth / viewWidth, videoHeight / viewHeight);
        matrix.postScale(viewWidth/videoWidth, viewWidth/videoWidth, viewWidth / 2f, viewHeight / 2f);
        setTransform(matrix);
        postInvalidate();
    }

    public void adjustVideoSizeForPk(boolean isPrepared) {
        int width = SpUtils.getScreenWidth(activity);
        int height = (int) (width / LiveStreamParams.WH_RATIO_PK);

        float x = width / 2f;
        float y = StatusBarConfig.getStatusBarHeight(activity) + SpUtils.dp2pix(activity, 64) + height / 2f;

        PointF pivot = new PointF(x, y);
        ALog.e("=====>", "pk video view center point is " + pivot);
        if (isPrepared) {
            PlayerVideoSizeUtils.adjustForPreparePk(this, pivot);
        } else {
            PlayerVideoSizeUtils.adjustViewSizePosition(this, true, pivot);
        }
    }

    public void adjustVideoSizeForNormal() {
        PlayerVideoSizeUtils.adjustViewSizePosition(this);
    }

    /**
     * 获取播放器播放控制
     */
    public PlayerControl getPlayerControl() {
        if (playerControl == null || playerControl.isReleased()) {
            playerControl = new PlayerControl(activity, playerNotify);
            return playerControl;
        }
        return playerControl;
    }

    private void changeErrorState(boolean error, int type) {
        if (!canRender) {
            return;
        }
        if (error) {
            getPlayerControl().reset();
            if (type == AudienceErrorStateView.TYPE_FINISHED) {
                release();
            } else {
                getPlayerControl().release();
            }
        }
    }
}
