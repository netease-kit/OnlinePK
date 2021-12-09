package com.netease.biz_live.yunxin.live.utils

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.ActivityManager.RunningAppProcessInfo
import android.content.Context
import android.content.Intent
import com.netease.yunxin.kit.alog.ALog

object SysUtil {
    private const val TAG = "SysUtil"

    @JvmStatic
    fun isAppRunningForeground(context: Context): Boolean {
        val activityManager =
            (context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager)
        val runningAppProcessList = activityManager.runningAppProcesses
        for (runningAppProcessInfo in runningAppProcessList) {
            if (runningAppProcessInfo.importance == RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                && runningAppProcessInfo.processName == context.applicationInfo.processName
            ) {
                ALog.d(TAG,"isAppRunningForeground true")
                return true
            }
        }
        ALog.d(TAG,"isAppRunningForeground false")
        return false
    }


    @JvmStatic
    @SuppressLint("NewApi")
    fun wakeupAppToForeground(context: Context, Class: Class<*>?) {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val taskInfoList = activityManager.getRunningTasks(20)
        /**枚举进程 */
        for (taskInfo in taskInfoList) {
            //*找到本应用的 task，并将它切换到前台
            if (taskInfo.baseActivity!!.packageName == context.packageName) {
                ALog.d(TAG, "timerTask  pid " + taskInfo.id)
                ALog.d(TAG, "timerTask  processName " + taskInfo.topActivity!!.packageName)
                ALog.d(TAG, "timerTask  getPackageName " + context.packageName)
                activityManager.moveTaskToFront(taskInfo.id, ActivityManager.MOVE_TASK_WITH_HOME)
                val intent = Intent(context, Class)
                intent.addCategory(Intent.CATEGORY_LAUNCHER)
                intent.action = Intent.ACTION_MAIN
                intent.flags =
                    Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
                context.startActivity(intent)
                break
            }
        }
    }
}