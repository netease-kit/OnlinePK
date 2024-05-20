// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertcfaceunity;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import java.util.HashMap;
import java.util.Map;

/** Generated class from Pigeon. */
@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression"})
public class Messages {

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class NECreateFaceUnityRequest {
    private byte[] beautyKey;

    public byte[] getBeautyKey() {
      return beautyKey;
    }

    public void setBeautyKey(byte[] setterArg) {
      this.beautyKey = setterArg;
    }

    private String logDir;

    public String getLogDir() {
      return logDir;
    }

    public void setLogDir(String setterArg) {
      this.logDir = setterArg;
    }

    private Long logLevel;

    public Long getLogLevel() {
      return logLevel;
    }

    public void setLogLevel(Long setterArg) {
      this.logLevel = setterArg;
    }

    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("beautyKey", beautyKey);
      toMapResult.put("logDir", logDir);
      toMapResult.put("logLevel", logLevel);
      return toMapResult;
    }

    static NECreateFaceUnityRequest fromMap(Map<String, Object> map) {
      NECreateFaceUnityRequest fromMapResult = new NECreateFaceUnityRequest();
      Object beautyKey = map.get("beautyKey");
      fromMapResult.beautyKey = (byte[]) beautyKey;
      Object logDir = map.get("logDir");
      fromMapResult.logDir = (String) logDir;
      Object logLevel = map.get("logLevel");
      fromMapResult.logLevel =
          (logLevel == null)
              ? null
              : ((logLevel instanceof Integer) ? (Integer) logLevel : (Long) logLevel);
      return fromMapResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class NEFUInt {
    private Long value;

    public Long getValue() {
      return value;
    }

    public void setValue(Long setterArg) {
      this.value = setterArg;
    }

    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("value", value);
      return toMapResult;
    }

    static NEFUInt fromMap(Map<String, Object> map) {
      NEFUInt fromMapResult = new NEFUInt();
      Object value = map.get("value");
      fromMapResult.value =
          (value == null) ? null : ((value instanceof Integer) ? (Integer) value : (Long) value);
      return fromMapResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class NEFUDouble {
    private Double value;

    public Double getValue() {
      return value;
    }

    public void setValue(Double setterArg) {
      this.value = setterArg;
    }

    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("value", value);
      return toMapResult;
    }

    static NEFUDouble fromMap(Map<String, Object> map) {
      NEFUDouble fromMapResult = new NEFUDouble();
      Object value = map.get("value");
      fromMapResult.value = (Double) value;
      return fromMapResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class NEFUString {
    private String value;

    public String getValue() {
      return value;
    }

    public void setValue(String setterArg) {
      this.value = setterArg;
    }

    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("value", value);
      return toMapResult;
    }

    static NEFUString fromMap(Map<String, Object> map) {
      NEFUString fromMapResult = new NEFUString();
      Object value = map.get("value");
      fromMapResult.value = (String) value;
      return fromMapResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class SetFaceUnityParamsRequest {
    private Double filterLevel;

    public Double getFilterLevel() {
      return filterLevel;
    }

    public void setFilterLevel(Double setterArg) {
      this.filterLevel = setterArg;
    }

    private Double colorLevel;

    public Double getColorLevel() {
      return colorLevel;
    }

    public void setColorLevel(Double setterArg) {
      this.colorLevel = setterArg;
    }

    private Double redLevel;

    public Double getRedLevel() {
      return redLevel;
    }

    public void setRedLevel(Double setterArg) {
      this.redLevel = setterArg;
    }

    private Double blurLevel;

    public Double getBlurLevel() {
      return blurLevel;
    }

    public void setBlurLevel(Double setterArg) {
      this.blurLevel = setterArg;
    }

    private Double eyeBright;

    public Double getEyeBright() {
      return eyeBright;
    }

    public void setEyeBright(Double setterArg) {
      this.eyeBright = setterArg;
    }

    private Double eyeEnlarging;

    public Double getEyeEnlarging() {
      return eyeEnlarging;
    }

    public void setEyeEnlarging(Double setterArg) {
      this.eyeEnlarging = setterArg;
    }

    private Double cheekThinning;

    public Double getCheekThinning() {
      return cheekThinning;
    }

    public void setCheekThinning(Double setterArg) {
      this.cheekThinning = setterArg;
    }

    private String filterName;

    public String getFilterName() {
      return filterName;
    }

    public void setFilterName(String setterArg) {
      this.filterName = setterArg;
    }

    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("filterLevel", filterLevel);
      toMapResult.put("colorLevel", colorLevel);
      toMapResult.put("redLevel", redLevel);
      toMapResult.put("blurLevel", blurLevel);
      toMapResult.put("eyeBright", eyeBright);
      toMapResult.put("eyeEnlarging", eyeEnlarging);
      toMapResult.put("cheekThinning", cheekThinning);
      toMapResult.put("filterName", filterName);
      return toMapResult;
    }

    static SetFaceUnityParamsRequest fromMap(Map<String, Object> map) {
      SetFaceUnityParamsRequest fromMapResult = new SetFaceUnityParamsRequest();
      Object filterLevel = map.get("filterLevel");
      fromMapResult.filterLevel = (Double) filterLevel;
      Object colorLevel = map.get("colorLevel");
      fromMapResult.colorLevel = (Double) colorLevel;
      Object redLevel = map.get("redLevel");
      fromMapResult.redLevel = (Double) redLevel;
      Object blurLevel = map.get("blurLevel");
      fromMapResult.blurLevel = (Double) blurLevel;
      Object eyeBright = map.get("eyeBright");
      fromMapResult.eyeBright = (Double) eyeBright;
      Object eyeEnlarging = map.get("eyeEnlarging");
      fromMapResult.eyeEnlarging = (Double) eyeEnlarging;
      Object cheekThinning = map.get("cheekThinning");
      fromMapResult.cheekThinning = (Double) cheekThinning;
      Object filterName = map.get("filterName");
      fromMapResult.filterName = (String) filterName;
      return fromMapResult;
    }
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter. */
  public interface NEFTFaceUnityEngineApi {
    NEFUInt create(NECreateFaceUnityRequest arg);

    NEFUInt setFilterLevel(NEFUDouble arg);

    NEFUInt setFilterName(NEFUString arg);

    NEFUInt setColorLevel(NEFUDouble arg);

    NEFUInt setRedLevel(NEFUDouble arg);

    NEFUInt setBlurLevel(NEFUDouble arg);

    NEFUInt setEyeEnlarging(NEFUDouble arg);

    NEFUInt setCheekThinning(NEFUDouble arg);

    NEFUInt setEyeBright(NEFUDouble arg);

    NEFUInt setMultiFUParams(SetFaceUnityParamsRequest arg);

    NEFUInt release();

    /**
     * Sets up an instance of `NEFTFaceUnityEngineApi` to handle messages through the
     * `binaryMessenger`.
     */
    static void setup(BinaryMessenger binaryMessenger, NEFTFaceUnityEngineApi api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.create",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  NECreateFaceUnityRequest input =
                      NECreateFaceUnityRequest.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.create(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.setFilterLevel",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  NEFUDouble input = NEFUDouble.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.setFilterLevel(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.setFilterName",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  NEFUString input = NEFUString.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.setFilterName(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.setColorLevel",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  NEFUDouble input = NEFUDouble.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.setColorLevel(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.setRedLevel",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  NEFUDouble input = NEFUDouble.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.setRedLevel(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.setBlurLevel",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  NEFUDouble input = NEFUDouble.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.setBlurLevel(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.setEyeEnlarging",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  NEFUDouble input = NEFUDouble.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.setEyeEnlarging(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.setCheekThinning",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  NEFUDouble input = NEFUDouble.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.setCheekThinning(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.setEyeBright",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  NEFUDouble input = NEFUDouble.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.setEyeBright(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.setMultiFUParams",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  SetFaceUnityParamsRequest input =
                      SetFaceUnityParamsRequest.fromMap((Map<String, Object>) message);
                  NEFUInt output = api.setMultiFUParams(input);
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.NEFTFaceUnityEngineApi.release",
                new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  NEFUInt output = api.release();
                  wrapped.put("result", output.toMap());
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }

  private static Map<String, Object> wrapError(Throwable exception) {
    Map<String, Object> errorMap = new HashMap<>();
    errorMap.put("message", exception.toString());
    errorMap.put("code", exception.getClass().getSimpleName());
    errorMap.put("details", null);
    return errorMap;
  }
}
