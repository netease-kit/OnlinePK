// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUManager.h"
#import <CoreMotion/CoreMotion.h>
#import <Flutter/Flutter.h>
#import <sys/utsname.h>
#import "FULiveModel.h"

@interface FUManager () {
  int items[FUNamaHandleTotal];
}

@property(nonatomic, strong) dispatch_queue_t asyncLoadQueue;
@property(nonatomic, assign) BOOL isInitBeauty;  // 是否开启美颜

@end

static FUManager *shareManager = NULL;

@implementation FUManager

+ (FUManager *)shareManager {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shareManager = [[FUManager alloc] init];
  });

  return shareManager;
}

- (instancetype)init {
  if (self = [super init]) {
    _asyncLoadQueue = dispatch_queue_create("com.faceLoadItem", DISPATCH_QUEUE_SERIAL);
    /**这里新增了一个参数shouldCreateContext，设为YES的话，不用在外部设置context操作，我们会在内部创建并持有一个context。
     还有设置为YES,则需要调用FURenderer.h中的接口，不能再调用funama.h中的接口。*/

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    //        [[FURenderer shareRenderer] setupWithData:nil dataSize:0 ardata:nil
    //        authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];

    CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);

    NSLog(@"---%lf", endTime);
  }

  return self;
}

- (void)setupWithKey:(FlutterStandardTypedData *)key {
  if (_isInitBeauty == NO) {
    [[FURenderer shareRenderer] setupWithData:nil
                                     dataSize:0
                                       ardata:nil
                                  authPackage:(void *)key.data.bytes
                                     authSize:(int)key.data.length
                          shouldCreateContext:YES];
    _isInitBeauty = YES;

    [self loadFilter];
    /* 加载AI模型 */
    [self loadAIModle];
    [self setDefaultRotationMode:3];
  }
}

- (void)loadAIModle {
  NSData *ai_face_processor = [NSData
      dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_face_processor.bundle"
                                                             ofType:nil]];
  [FURenderer loadAIModelFromPackage:(void *)ai_face_processor.bytes
                                size:(int)ai_face_processor.length
                              aitype:FUAITYPE_FACEPROCESSOR];
}
- (void)loadFilter {
  dispatch_async(_asyncLoadQueue, ^{
    if (self->items[FUNamaHandleTypeBeauty] == 0) {
      NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification.bundle"
                                                       ofType:nil];
      self->items[FUNamaHandleTypeBeauty] = [FURenderer itemWithContentsOfFile:path];

      /* 默认精细磨皮 */
      /*
       blur_level: 磨皮程度，取值范围0.0-6.0，默认6.0
       heavy_blur: 朦胧磨皮开关，0为清晰磨皮，1为朦胧磨皮
       blur_type：此参数优先级比heavy_blur低，在使用时要将heavy_blur设为0，0 清晰磨皮  1 朦胧磨皮
       2精细磨皮 blur_use_mask:
       默认为0，1为开启基于人脸的磨皮mask，0为不使用mask正常磨皮。只在blur_type为2时生效。开启此功能需要高级美颜权限。
       */
      [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                      withName:@"heavy_blur"
                         value:@(0)];
      [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                      withName:@"blur_type"
                         value:@(2)];
      /* 默认自定义脸型 */
      [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                      withName:@"face_shape"
                         value:@(4)];

      NSMutableDictionary *fliterParams = [NSMutableDictionary dictionary];
      [fliterParams setObject:@"origin" forKey:@"filterName"];
      [fliterParams setObject:@(1) forKey:@"filterLevel"];
      [fliterParams setObject:@(0) forKey:@"colorLevel"];
      [fliterParams setObject:@(0) forKey:@"redLevel"];
      [fliterParams setObject:@(0) forKey:@"blurLevel"];
      [fliterParams setObject:@(0) forKey:@"eyeBright"];
      [fliterParams setObject:@(0) forKey:@"eyeEnlarging"];
      [fliterParams setObject:@(0) forKey:@"cheekThinning"];
      [self loadFilter:fliterParams];
    }
  });
}

- (BOOL)isInitBeauty {
  return _isInitBeauty;
}

- (void)setDefaultRotationMode:(int)mode {
  fuSetDefaultRotationMode(mode);
}

#pragma mark -  加载bundle
/**加载美颜道具*/
- (void)loadFilter:(NSDictionary *)fliterParams {
  if (_isInitBeauty) {
    dispatch_async(_asyncLoadQueue, ^{
      if (self->items[FUNamaHandleTypeBeauty]) {
        /* 默认精细磨皮 */
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                        withName:@"filter_name"
                           value:[fliterParams objectForKey:@"filterName"]];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                        withName:@"filter_level"
                           value:[fliterParams objectForKey:@"filterLevel"]];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                        withName:@"color_level"
                           value:[fliterParams objectForKey:@"colorLevel"]];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                        withName:@"red_level"
                           value:[fliterParams objectForKey:@"redLevel"]];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                        withName:@"blurLevel"
                           value:[fliterParams objectForKey:@"blur_level"]];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                        withName:@"eye_enlarging"
                           value:[fliterParams objectForKey:@"eyeEnlarging"]];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty]
                        withName:@"cheek_thinning"
                           value:[fliterParams objectForKey:@"cheekThinning"]];

        NSLog(@"加载美颜参数: %@ ,%@", fliterParams.allValues, fliterParams.allKeys);
      }
    });
  }
}

- (int)setParamItemAboutType:(FUNamaHandleType)type name:(NSString *)paramName value:(id)value {
  dispatch_async(_asyncLoadQueue, ^{
    if (self->items[type]) {
      [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:paramName value:value];
    }
  });
  return 0;
}

/**将道具绘制到pixelBuffer*/
- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer {
  CVPixelBufferRef buffer = [[FURenderer shareRenderer]
      renderPixelBuffer:pixelBuffer
            withFrameId:0
                  items:items
              itemCount:sizeof(items) / sizeof(int)
                  flipx:YES];  // flipx 参数设为YES可以使道具做水平方向的镜像翻转

  return buffer;
}

- (void)destroyAllItems {
  //     [FURenderer destroyAllItems];
}

@end
