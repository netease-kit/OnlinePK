package com.netease.biz_live.yunxin.live.audience.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.netease.biz_live.BuildConfig;
import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.dialog.DumpDialog;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;

/**
 * @author sunkeding
 * 多功能按钮，承接观众举手申请上麦及观众推流参数设置两个功能
 */
public class MultiFunctionButton extends androidx.appcompat.widget.AppCompatImageView {
    private int type = Type.APPLY_SEAT_DISABLE;
    public interface Type {
        /**
         * 正常状态，点击按钮申请连麦
         */
        int APPLY_SEAT_ENABLE = 0;
        /**
         * 连麦申请中，按钮置灰不可点击
         */
        int APPLY_SEAT_DISABLE = 1;
        /**
         * 连麦中，点击按钮弹出设置弹窗
         */
        int LINK_SEATS_SETTING = 2;
    }

    public MultiFunctionButton(Context context) {
        super(context);
        init(context);
    }

    public MultiFunctionButton(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public MultiFunctionButton(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        setOnClickListener(v -> {
            if (onButtonClickListener == null || type == Type.APPLY_SEAT_DISABLE) {
                return;
            }
            if (type == Type.APPLY_SEAT_ENABLE) {
                onButtonClickListener.applySeat();
            } else if (type == Type.LINK_SEATS_SETTING) {
                onButtonClickListener.showLinkSeatsStatusDialog();
            }
        });
        // 连麦观众设置按钮新增dump音频功能
        setOnLongClickListener(v -> {
            if (BuildConfig.DEBUG&&type == Type.LINK_SEATS_SETTING&&context instanceof BaseActivity){
                BaseActivity activity = (BaseActivity) context;
                DumpDialog.showDialog(activity.getSupportFragmentManager());
            }
            return false;
        });
    }

    public void setType(int type) {
        this.type = type;
        if (type == Type.APPLY_SEAT_ENABLE) {
            setImageResource(R.drawable.biz_live_raise_hand_enable);
        } else if (type == Type.APPLY_SEAT_DISABLE) {
            setImageResource(R.drawable.biz_live_raise_hand_disable);
        } else if (type == Type.LINK_SEATS_SETTING) {
            setImageResource(R.drawable.biz_live_push_setting);
        }
    }


    public void setOnButtonClickListener(OnButtonClickListener onButtonClickListener) {
        this.onButtonClickListener = onButtonClickListener;
    }
    private OnButtonClickListener onButtonClickListener;
    public interface OnButtonClickListener {
        void applySeat();
        void showLinkSeatsStatusDialog();
    }
}
