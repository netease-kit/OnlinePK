//
//  NETSLiveApi.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/3.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NETSRequest.h"
#import "NETSLiveModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface NETSLiveApi : NSObject

/**
 请求直播列表
 @prram live        - 类型: -1-全部 1-直播 2-PK直播
 @prram pageNum     - 页码
 @prram pageSize    - 每页展示数据数量
 @param completionHandle    - 请求完成闭包
 @param errorHandle         - 请求失败闭包
 */
+ (void)fetchListWithLive:(NETSLiveListType)live
                  pageNum:(int32_t)pageNum
                 pageSize:(int32_t)pageSize
         completionHandle:(nullable NETSRequestCompletion)completionHandle
              errorHandle:(nullable NETSRequestError)errorHandle;

/**
 随机获取直播间主题
 */
+ (void)randowToipcWithCompletionHandle:(nullable NETSRequestCompletion)completionHandle
                            errorHandle:(nullable NETSRequestError)errorHandle;

/**
 随机获取直播间封面
 */
+ (void)randomCoverWithCompletionHandle:(nullable NETSRequestCompletion)completionHandle
                            errorHandle:(nullable NETSRequestError)errorHandle;

/**
 创建直播间
 */
+ (void)createLiveRoomWithTopic:(NSString *)topic
                       coverUrl:(NSString *)coverUrl
                           type:(NETSLiveType)type
                  parentLiveCid:(nullable NSString *)parentLiveCid
               completionHandle:(NETSRequestCompletion)completionHandle
                    errorHandle:(nullable NETSRequestError)errorHandle;

/**
 主播开始PK
 */
+ (void)startPKWithCid:(NSString *)cid
      completionHandle:(NETSRequestCompletion)completionHandle
           errorHandle:(nullable NETSRequestError)errorHandle;

/**
 加入直播房间
 @param liveCid             - 回到原单人房间,传自己的直播间cid; 邀请者进入pk房间,传自己的单人直播间cid
 @param parentLiveCid       - 单人直播间cid
 @param liveType            - 直播间类型
 @param completionHandle    - 请求结束闭包
 @param errorHandle         - 请求失败闭包
 */
+ (void)joinLiveRoomWithLiveId:(NSString *)liveCid
                 parentLiveCid:(nullable NSString *)parentLiveCid
                      liveType:(NETSLiveType)liveType
              completionHandle:(NETSRequestCompletion)completionHandle
                   errorHandle:(nullable NETSRequestError)errorHandle;

/**
 主播结束PK
 */
+ (void)endPKWithCid:(NSString *)cid
    completionHandle:(NETSRequestCompletion)completionHandle
         errorHandle:(nullable NETSRequestError)errorHandle;

/**
 主播关闭直播间
 */
+ (void)closeLiveRoomWithCid:(NSString *)cid
            completionHandle:(NETSRequestCompletion)completionHandle
                 errorHandle:(nullable NETSRequestError)errorHandle;

/**
 直播间打赏
 */
+ (void)rewardLiveCid:(NSString *)liveCid
             liveType:(NETSLiveType)liveType
      anchorAccountId:(NSString *)anchorAccountId
               giftId:(NSInteger)giftId
     completionHandle:(nullable NETSRequestCompletion)completionHandle
          errorHandle:(nullable NETSRequestError)errorHandle;

/**
 获取pk打赏榜单
 @param liveCid         - live cid
 @param liveType        - 直播类型
 @param anchorAccountId - 主播账号
 @param successBlock    - 成功闭包
 @param failedBlock     - 失败闭包
 */
+ (void)getPkLiveContriListWithLiveCid:(NSString *)liveCid
                              liveType:(NETSLiveType)liveType
                       anchorAccountId:(NSString *)anchorAccountId
                          successBlock:(nullable NETSRequestCompletion)successBlock
                           failedBlock:(nullable NETSRequestError)failedBlock;


/// 麦位音视频操作
/// @param roomId 房间id
/// @param userId 用户id
/// @param isOpenVideo 是否打开视屏  1 打开 0 关闭
/// @param isOpenAudio 是否打开音频  1 打开 0 关闭
/// @param successBlock 成功闭包
/// @param failedBlock 失败闭包
+ (void)requestChangeSeatsStatusWithRoomId:(NSString *)roomId
                                  userId:(NSString *)userId
                                   video:(int)isOpenVideo
                                   audio:(int)isOpenAudio
                             successBlock:(nullable NETSRequestCompletion)successBlock
                              failedBlock:(nullable NETSRequestError)failedBlock;
@end

NS_ASSUME_NONNULL_END
