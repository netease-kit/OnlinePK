package com.netease.biz_live.yunxin.live.floatplay

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.util.AttributeSet
import android.view.Gravity
import android.view.MotionEvent
import android.view.WindowManager
import android.widget.FrameLayout
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.utils.ClickUtils.isFastClick

/**
 * 悬浮窗组件
 */
class FloatView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {
    companion object{
        private const val TAG="FloatView"
    }
    /**
     * 系统状态栏的高度
     */
    private var mStatusBarHeight = 0

    /**
     * 按下事件距离屏幕左边界的距离
     */
    private var mXDownInScreen = 0f

    /**
     * 按下事件距离屏幕上边界的距离
     */
    private var mYDownInScreen = 0f

    /**
     * 滑动事件距离屏幕左边界的距离
     */
    private var mXInScreen = 0f

    /**
     * 滑动事件距离屏幕上边界的距离
     */
    private var mYInScreen = 0f

    /**
     * 滑动事件距离自身左边界的距离
     */
    private var mXInView = 0f

    /**
     * 滑动事件距离自身上边界的距离
     */
    private var mYInView = 0f
    private var mWindowManager: WindowManager? = null
    private var mWindowParams: WindowManager.LayoutParams? = null

    init {
        initWindow()
    }

    private fun initWindow() {
        mWindowManager =
            context.applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        mWindowParams = WindowManager.LayoutParams()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mWindowParams!!.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            mWindowParams!!.type = WindowManager.LayoutParams.TYPE_PHONE
        }
        mWindowParams!!.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
        mWindowParams!!.windowAnimations = R.style.FloatWindowAnimation
        mWindowParams!!.format = PixelFormat.TRANSLUCENT
        mWindowParams!!.gravity = Gravity.LEFT or Gravity.TOP
    }

    fun addToWindow(): Boolean {
        return if (mWindowManager != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                if (!isAttachedToWindow) {
                    mWindowManager!!.addView(this, mWindowParams)
                    true
                } else {
                    false
                }
            } else {
                try {
                    if (parent == null) {
                        mWindowManager!!.addView(this, mWindowParams)
                    }
                    true
                } catch (e: Exception) {
                    FloatPlayLogUtil.log(TAG,"addToWindow e:$e")
                    false
                }
            }
        } else {
            false
        }
    }

    fun removeFromWindow(): Boolean {
        return if (mWindowManager != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                if (isAttachedToWindow) {
                    mWindowManager!!.removeViewImmediate(this)
                    true
                } else {
                    false
                }
            } else {
                try {
                    if (parent != null) {
                        mWindowManager!!.removeViewImmediate(this)
                    }
                    true
                } catch (e: Exception) {
                    FloatPlayLogUtil.log(TAG,"removeFromWindow e:$e")
                    false
                }
            }
        } else {
            false
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                mXInView = event.x
                mYInView = event.y
                mXDownInScreen = event.rawX
                mYDownInScreen = event.rawY - statusBarHeight
                mXInScreen = event.rawX
                mYInScreen = event.rawY - statusBarHeight
            }
            MotionEvent.ACTION_MOVE -> {
                mXInScreen = event.rawX
                mYInScreen = event.rawY - statusBarHeight
                val x = (mXInScreen - mXInView).toInt()
                val y = (mYInScreen - mYInView).toInt()
                mWindowParams!!.x = x
                mWindowParams!!.y = y
                mWindowManager!!.updateViewLayout(this, mWindowParams)
            }
            MotionEvent.ACTION_UP -> if (mXDownInScreen == mXInScreen && mYDownInScreen == mYInScreen) { //手指没有滑动视为点击，回到窗口模式
                if (!isFastClick() && onFloatViewClickListener != null) {
                    FloatPlayLogUtil.log(TAG,"click float view")
                    onFloatViewClickListener!!.onClick()
                }
            }
            else -> {
            }
        }
        return true
    }

    private val statusBarHeight: Int
        private get() {
            if (mStatusBarHeight == 0) {
                try {
                    val c = Class.forName("com.android.internal.R\$dimen")
                    val o = c.newInstance()
                    val field = c.getField("status_bar_height")
                    val x = field[o] as Int
                    mStatusBarHeight = resources.getDimensionPixelSize(x)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            return mStatusBarHeight
        }

    fun update(width: Int, height: Int) {
        mWindowParams!!.width = width
        mWindowParams!!.height = height
        mWindowManager!!.updateViewLayout(this, mWindowParams)
    }

    fun update(width: Int, height: Int, x: Int, y: Int) {
        mWindowParams!!.width = width
        mWindowParams!!.height = height
        mWindowParams!!.x = x
        mWindowParams!!.y = y
        mWindowManager!!.updateViewLayout(this, mWindowParams)
    }

    private var onFloatViewClickListener: OnFloatViewClickListener? = null
    fun setOnFloatViewClickListener(onFloatViewClickListener: OnFloatViewClickListener?) {
        this.onFloatViewClickListener = onFloatViewClickListener
    }

    interface OnFloatViewClickListener {
        fun onClick()
    }
}