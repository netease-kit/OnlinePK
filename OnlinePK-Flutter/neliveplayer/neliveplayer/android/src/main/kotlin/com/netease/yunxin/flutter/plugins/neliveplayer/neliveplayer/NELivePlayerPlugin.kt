/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.flutter.plugins.neliveplayer.neliveplayer

import androidx.annotation.NonNull
import com.netease.yunxin.flutter.plugins.neliveplayer.neliveplayer.liveplayer.NELivePlayerPlatform
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** NELivePlayerPlugin */
class NELivePlayerPlugin : FlutterPlugin {

    private val livePlayerPlatform = NELivePlayerPlatform()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        livePlayerPlatform.onAttachedToEngine(flutterPluginBinding)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        livePlayerPlatform.onDetachedFromEngine(binding)
    }
}
