# 跑通互动直播
互动直播示例代码提供普通的单主播直播已经PK直播和连麦直播

## 前提条件
在开始运行示例项目之前，请确保您已完成以下操作：  
联系云信商务获取开通以下权限，并联系技术支持配置产品服务和功能
### 为此应用开通以下相关服务与抄送：
* [应用创建和服务开通](https://github.com/netease-kit/documents/blob/main/%E5%9C%BA%E6%99%AF%E6%96%B9%E6%A1%88/%E4%BA%92%E5%8A%A8%E7%9B%B4%E6%92%AD/%E5%BA%94%E7%94%A8%E5%88%9B%E5%BB%BA%E5%92%8C%E6%9C%8D%E5%8A%A1%E5%BC%80%E9%80%9A.md)
* 云信控制台配置参考[服务配置](https://github.com/netease-kit/documents/blob/main/%E5%9C%BA%E6%99%AF%E6%96%B9%E6%A1%88/%E4%BA%92%E5%8A%A8%E7%9B%B4%E6%92%AD/%E6%9C%8D%E5%8A%A1%E9%85%8D%E7%BD%AE.md)
* 如需使用美颜功能请联系相芯获取美颜证书 [相芯](https://www.faceunity.com/)

## 开发环境
在开始运行示例项目之前，请确保开发环境满足以下要求：

| 环境要求         | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| JDK 版本         | 1.8.0 及以上版本                                             |
| Android API 版本 | API 23、Android 6.0 及以上版本                               |
| CPU架构          | ARM64、ARMV7                                                 |
| IDE              | Android Studio4.0及以上                                               |
| 其他             | 依赖 Androidx，不支持 support 库。Android 系统 4.3 或以上版本的移动设备。 |

## 示例项目结构
|  目录   | 说明  |
|  ----  | ----  |
| app  | 应用主入口包含外部页面框架。 |
| biz-user | 用户相关实现 |
| lib-user  | 用户lib |
| lib-modularity  | app模块化 |
| lib-basic  | 基础lib |
| lib-beauty-faceunity  | 美颜lib，基于相芯 |
| lib-network-kt | kotlin 使用的网络库 |
| biz-live | 直播业务实现，主要是UI方面 |
| lib-live-room-service | 直播房间服务 |
| lib-live-pk-service | Pk相关功能服务 |

## 运行示例源码
1. GitHub下载源代码 [源码](https://github.com/netease-kit/OnlinePK/tree/master/OnlinePK-Android)

2. 导入Android Studio

3. 找到工程目录下的config.properties文件，里面替换成自己的APP_KEY，请[联系云信商务经理](https://yunxin.163.com/bizQQWPA.html)开通音视频功能

    ```
    APP_KEY="请输入你的app key"
    BASE_URL=https://yiyong.netease.im/
   
    ```

4. 如果需要使用美颜功能请使用自己的相芯证书替换lib-beauty-faceunity/src/main/java/com/beautyFaceunity/authpack.java 证书文件
    ```
    package com.faceunity;
    
    import java.security.MessageDigest;
    
    public class authpack {
    
    }
    ```

5. 运行在自己的Android设备上
