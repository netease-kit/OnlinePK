package com.netease.biz_live.yunxin.live.dialog;

import android.view.View;
import android.widget.Button;

import androidx.fragment.app.FragmentManager;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_live.R;
import com.netease.lava.nertc.sdk.NERtcEx;

/**
 * dump dialog
 */
public class DumpDialog extends BaseBottomDialog {

    Button btnStart;

    Button btnStop;

    @Override
    protected int getResourceLayout() {
        return R.layout.test_dump_layout;
    }

    @Override
    protected void initView(View rootView) {
        super.initView(rootView);
        btnStart = rootView.findViewById(R.id.btn_start_dump);
        btnStop = rootView.findViewById(R.id.btn_stop_dump);
    }

    @Override
    protected void initData() {
        super.initData();
        btnStart.setOnClickListener(v -> {
            btnStart.setEnabled(false);
            ToastUtils.showLong("开始dump音频");
            NERtcEx.getInstance().startAudioDump();
        });

        btnStop.setOnClickListener(v -> {
            btnStart.setEnabled(true);
            ToastUtils.showLong("dump已结束");
            NERtcEx.getInstance().stopAudioDump();
        });
    }


    public static void showDialog(FragmentManager fragmentManager) {
        DumpDialog dumpDialog = new DumpDialog();
        dumpDialog.show(fragmentManager, "dumpDialog");
    }


}
