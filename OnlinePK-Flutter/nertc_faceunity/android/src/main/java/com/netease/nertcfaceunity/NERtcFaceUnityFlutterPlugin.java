// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertcfaceunity;

import android.content.Context;
import android.hardware.Camera;
import android.util.Log;
import androidx.annotation.NonNull;
import com.beautyFaceunity.FURenderer;
import com.beautyFaceunity.utils.FileUtils;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.video.NERtcVideoFrame;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/** NERtcFaceUnityFlutterPlugin */
public class NERtcFaceUnityFlutterPlugin implements FlutterPlugin, Messages.NEFTFaceUnityEngineApi {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private Context context;
  private FURenderer mFuRender; //美颜效果

  public NERtcFaceUnityFlutterPlugin() {}

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    Messages.NEFTFaceUnityEngineApi.setup(flutterPluginBinding.getBinaryMessenger(), this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public Messages.NEFUInt create(Messages.NECreateFaceUnityRequest arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    byte[] beautyKey = arg.getBeautyKey();
    if (beautyKey != null) {
      try {
        if (!FURenderer.isLibInit()) {
          initFUBeauty(beautyKey);
        }
      } catch (UnsatisfiedLinkError e) {
        Log.e("NERtcEngine", "Create FU engine error: class is not load");
        result.setValue(-1L);
        return result;
      }
    } else {
      Log.e("NERtcEngine", "Create FU engine error: app key is null");
      result.setValue(-2L);
      return result;
    }
    result.setValue(0L);
    return result;
  }

  @Override
  public Messages.NEFUInt setFilterLevel(Messages.NEFUDouble arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null && FURenderer.isLibInit()) {
      mFuRender.onFilterLevelSelected(arg.getValue().floatValue());
      result.setValue(0L);
    } else {
      result.setValue(-1L);
    }
    return result;
  }

  @Override
  public Messages.NEFUInt setFilterName(Messages.NEFUString arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null && FURenderer.isLibInit()) {
      mFuRender.onFilterNameSelected(arg.getValue());
      result.setValue(0L);
    } else {
      result.setValue(-1L);
    }
    return result;
  }

  @Override
  public Messages.NEFUInt setColorLevel(Messages.NEFUDouble arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null && FURenderer.isLibInit()) {
      mFuRender.onColorLevelSelected(arg.getValue().floatValue());
      result.setValue(0L);
    } else {
      result.setValue(-1L);
    }
    return result;
  }

  @Override
  public Messages.NEFUInt setRedLevel(Messages.NEFUDouble arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null && FURenderer.isLibInit()) {
      mFuRender.onRedLevelSelected(arg.getValue().floatValue());
      result.setValue(0L);
    } else {
      result.setValue(-1L);
    }
    return result;
  }

  @Override
  public Messages.NEFUInt setBlurLevel(Messages.NEFUDouble arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null && FURenderer.isLibInit()) {
      mFuRender.onBlurLevelSelected(arg.getValue().floatValue());
      result.setValue(0L);
    } else {
      result.setValue(-1L);
    }
    return result;
  }

  @Override
  public Messages.NEFUInt setEyeEnlarging(Messages.NEFUDouble arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null && FURenderer.isLibInit()) {
      mFuRender.onEyeEnlargeSelected(arg.getValue().floatValue());
      result.setValue(0L);
    } else {
      result.setValue(-1L);
    }
    return result;
  }

  @Override
  public Messages.NEFUInt setCheekThinning(Messages.NEFUDouble arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null && FURenderer.isLibInit()) {
      mFuRender.onCheekThinningSelected(arg.getValue().floatValue());
      result.setValue(0L);
    } else {
      result.setValue(-1L);
    }
    return result;
  }

  @Override
  public Messages.NEFUInt setEyeBright(Messages.NEFUDouble arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null && FURenderer.isLibInit()) {
      mFuRender.onEyeBrightSelected(arg.getValue().floatValue());
      result.setValue(0L);
    } else {
      result.setValue(-1L);
    }
    return result;
  }

  private boolean initFUBeauty(byte[] beautyKey) {
    FURenderer.initFURenderer(context, beautyKey);
    //        if (!FURenderer.isLibInit) return false;
    ThreadHelper.getInstance()
        .execute(
            () -> {
              // 异步拷贝 assets 资源
              FileUtils.copyAssetsChangeFaceTemplate(context);
            });
    mFuRender =
        new FURenderer.Builder(context)
            .maxFaces(1)
            .inputImageOrientation(getCameraOrientation(Camera.CameraInfo.CAMERA_FACING_FRONT))
            .inputTextureType(FURenderer.FU_ADM_FLAG_EXTERNAL_OES_TEXTURE)
            .build();
    mFuRender.onSurfaceCreated();
    mFuRender.setBeautificationOn(true);
    //设置视频采集数据回调，用于美颜等操作
    NERtcEx.getInstance().setVideoCallback(this::onVideoCallback, true);
    return false;
  }

  private boolean onVideoCallback(NERtcVideoFrame neRtcVideoFrame) {
    //此处可自定义第三方的美颜实现
    if (mFuRender != null && FURenderer.isLibInit()) {
      neRtcVideoFrame.textureId =
          mFuRender.onDrawFrame(
              neRtcVideoFrame.data,
              neRtcVideoFrame.textureId,
              neRtcVideoFrame.width,
              neRtcVideoFrame.height);
      neRtcVideoFrame.format = NERtcVideoFrame.Format.TEXTURE_RGB;
      return true;
    }
    return false;
  }

  private int getCameraOrientation(int cameraFacing) {
    Camera.CameraInfo info = new Camera.CameraInfo();
    int cameraId = -1;
    int numCameras = Camera.getNumberOfCameras();
    for (int i = 0; i < numCameras; i++) {
      Camera.getCameraInfo(i, info);
      if (info.facing == cameraFacing) {
        cameraId = i;
        break;
      }
    }
    if (cameraId < 0) {
      // no front camera, regard it as back camera
      return 90;
    } else {
      return info.orientation;
    }
  }

  @Override
  public Messages.NEFUInt setMultiFUParams(Messages.SetFaceUnityParamsRequest arg) {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null && FURenderer.isLibInit()) {
      //            mFuRender.customFuItem(arg.getColorLevel().floatValue(),
      //                    arg.getFilterLevel().floatValue(), arg.getRedLevel().floatValue(),
      //                    arg.getEyeBright().floatValue(), arg.getBlurLevel().floatValue());
      result.setValue(0L);
    } else {
      result.setValue(-1L);
    }
    return result;
  }

  @Override
  public Messages.NEFUInt release() {
    Messages.NEFUInt result = new Messages.NEFUInt();
    if (mFuRender != null) {
      mFuRender.destroyLibData();
      mFuRender.onSurfaceDestroyed();
    }
    result.setValue(0L);
    return result;
  }
}
