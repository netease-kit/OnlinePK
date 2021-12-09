package com.netease.biz_live.yunxin.live.floatplay

import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.TextureView
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import com.blankj.utilcode.util.NetworkUtils
import com.blankj.utilcode.util.ToastUtils
import com.blankj.utilcode.util.Utils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.ui.view.BaseAudienceContentView
import com.netease.biz_live.yunxin.live.utils.SpUtils.dp2pix
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_network_kt.NetRequestCallback

/**
 * 小窗播放UI
 */
class FloatPlayLayout @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {
    var videoView: TextureView? = null
        private set
    var rtmpPullUrl=""
    private val onNetworkStatusChangedListener: NetworkUtils.OnNetworkStatusChangedListener =
        object : NetworkUtils.OnNetworkStatusChangedListener {
            override fun onDisconnected() {
                FloatPlayLogUtil.log(TAG,"onDisconnected")
            }

            override fun onConnected(networkType: NetworkUtils.NetworkType) {
                FloatPlayLogUtil.log(TAG,"onConnected:$networkType")
                if (!TextUtils.isEmpty(rtmpPullUrl)){
                    LiveVideoPlayerManager.getInstance().resumePlay(rtmpPullUrl)
                }
            }
        }

    init {
        LayoutInflater.from(context).inflate(R.layout.live_float_play_ui, this)
        videoView = findViewById<View>(R.id.videoView) as TextureView
        val ivClose = findViewById<View>(R.id.iv_close) as ImageView
        ivClose.setOnClickListener {
            release()
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        NetworkUtils.registerNetworkStatusChangedListener(onNetworkStatusChangedListener)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        NetworkUtils.unregisterNetworkStatusChangedListener(onNetworkStatusChangedListener)
    }

    fun setPlayUrl(url:String){
        rtmpPullUrl=url
    }

    fun release() {
        LiveRoomService.sharedInstance().leaveRoom(object :NetRequestCallback<Unit>{
            override fun success(info: Unit?) {
                ALog.d(TAG,"leaveRoom success")
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showLong(msg)
                ALog.d(TAG,"leaveRoom error")
            }

        })
        FloatPlayManager.stopFloatPlay()
        FloatPlayManager.release()
        LiveVideoPlayerManager.getInstance().release()
        AudienceDataManager.clear()
    }

    companion object {
        private const val TAG="FloatPlayLayout"
        //  pk直播 width 720, height 640
        //  单主播 width 720, height 1280
        @JvmField
        val SINGLE_ANCHOR_WIDTH = dp2pix(Utils.getApp(), 90f)

        @JvmField
        val SINGLE_ANCHOR_HEIGHT = dp2pix(Utils.getApp(), 160f)

        @JvmField
        val PK_LIVE_WIDTH = dp2pix(Utils.getApp(), 144f)

        @JvmField
        val PK_LIVE_HEIGHT = dp2pix(Utils.getApp(), 128f)

        @JvmField
        val MARGIN_RIGHT = dp2pix(Utils.getApp(), 20f)

        @JvmField
        val MARGIN_BOTTOM = dp2pix(Utils.getApp(), 120f)
    }
}