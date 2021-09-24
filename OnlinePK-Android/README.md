## 互动直播

### 前提条件

- 已在控制台创建应用，并获取了应用对应的 App Key。
- 已成功开通 IM 即时通讯产品的聊天室功能、音视频通话 2.0 产品。<br>
  聊天室功能需单独开通，若有需要，请联系您的对应销售或技术支持人员。

### 接入说明：
- 使用已经申请的appkey替换到config目录下的配置文件
  - 测试配置文件：test.properties 线上配置文件：online.properties
- 如果需要使用美颜相关功能，请申请相芯证书并替换authpack.java文件，此文件为相芯证书文件。并确认FURenderer.java文件中fixme部分。

### 代码结构说明
参考setting文件
 ```gradle
  include ':app'
/**
 * 用户相关实现
 */
include ':biz-user'

/**
 * 用户lib
 */
include ':lib-user'

/**
 * app模块化
 */
include ':lib-modularity'
/**
 * 基础lib
 */
include ':lib-basic'

/**
 * 美颜lib，基于相芯
 */
include ':lib-beauty-faceunity'

/**
 * kotlin 使用的网络库
 */
include ':lib-network-kt'

/**
 * 直播模块lib
 */
include ':lib-live'

/**
 * 直播业务实现，主要是UI方面
 */
include ':biz-live'

/**
 * 直播房间服务
 */
include ':lib-live-room-service'
/**
 * Pk 相关功能
 */
include ':lib-live-pk-service'
```

- 互动直播相关功能重点关注后三个model
- lib-beauty-faceunity 为相芯美颜相关的功能实现代码，如果确认接入，接入过程中美颜问题可直接咨询相芯相关技术支持


