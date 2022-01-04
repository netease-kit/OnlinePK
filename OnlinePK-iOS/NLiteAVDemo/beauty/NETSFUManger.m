//
//  NETSFUManger.m
//  NLiteAVDemo
//
//  Created by Think on 2020/11/17.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSFUManger.h"
#import <libCNamaSDK/FURenderer.h>
#import "authpack.h"
#import <libCNamaSDK/CNamaSDK.h>

static NETSFUManger *shareManager = NULL;

@interface NETSFUManger ()
{
    int items[NETSFUNamaHandleTotal];
    int frameID;
}

/// 操作队列
@property (nonatomic, strong) dispatch_queue_t  asyncLoadQueue;
/// 滤镜参数
@property (nonatomic, strong, readwrite) NSArray<NETSBeautyParam *> *filters;
/// 美肤参数
@property (nonatomic, strong, readwrite) NSArray<NETSBeautyParam *> *skinParams;

@end

@implementation NETSFUManger

+ (NETSFUManger *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[NETSFUManger alloc] init];
    });
    
    return shareManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _asyncLoadQueue = dispatch_queue_create("com.faceLoadItem", DISPATCH_QUEUE_SERIAL);
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        [[FURenderer shareRenderer] setupWithData:nil dataSize:0 ardata:nil authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];
        CFAbsoluteTime delay = (CFAbsoluteTimeGetCurrent() - startTime);
        YXAlogInfo(@"setup FU: ---%lf", delay);
        
        /* 加载AI模型 */
        [self loadAIModle];
        
        /* 美颜 */
        self.filters = [self originFilters];
        self.seletedFliter = [self.filters firstObject];
        self.skinParams = [self originSkinParams];
        
        [self loadFilter];
        
        [self setDefaultRotationMode:3];
    }
    return self;
}

-(void)loadAIModle
{
    NSData *ai_face_processor = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_face_processor.bundle" ofType:nil]];
    [FURenderer loadAIModelFromPackage:(void *)ai_face_processor.bytes size:(int)ai_face_processor.length aitype:FUAITYPE_FACEPROCESSOR];
}

- (void)loadFilter
{
    dispatch_async(_asyncLoadQueue, ^{
        if (self->items[NETSFUNamaHandleTypeBeauty] == 0) {

            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

            NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification.bundle" ofType:nil];
            self->items[NETSFUNamaHandleTypeBeauty] = [FURenderer itemWithContentsOfFile:path];

            /* 默认精细磨皮 */
            [FURenderer itemSetParam:self->items[NETSFUNamaHandleTypeBeauty] withName:@"heavy_blur" value:@(0)];
            [FURenderer itemSetParam:self->items[NETSFUNamaHandleTypeBeauty] withName:@"blur_type" value:@(2)];
            /* 默认自定义脸型 */
            [FURenderer itemSetParam:self->items[NETSFUNamaHandleTypeBeauty] withName:@"face_shape" value:@(4)];
            
            CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);

            YXAlogInfo(@"加载美颜道具耗时: %f ms", endTime * 1000.0);
     
        }
    });
}

- (void)setParamItemAboutType:(NETSFUNamaHandleType)type
                         name:(NSString *)paramName
                        value:(float)value
{
    dispatch_async(_asyncLoadQueue, ^{
        if (self->items[type]) {
            int res = [FURenderer itemSetParam:self->items[type] withName:paramName value:@(value)];
            YXAlogInfo(@"设置type(%lu)----参数（%@）-----值(%lf) -----res(%d) ----tracking(%d)", (unsigned long)type, paramName, value, res, [self isTracking]);
        }
    });
}

- (void)setBeautyParam:(NETSBeautyParam *)param
{
    if ([param.mParam isEqualToString:@"cheek_narrow"] || [param.mParam isEqualToString:@"cheek_small"]) {
        // 程度值 只去一半
        [[NETSFUManger shared] setParamItemAboutType:NETSFUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 0.5];
    } else if([param.mParam isEqualToString:@"blur_level"]) {
        // 磨皮 0~6
        [[NETSFUManger shared] setParamItemAboutType:NETSFUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 6];
    } else {
        [[NETSFUManger shared] setParamItemAboutType:NETSFUNamaHandleTypeBeauty name:param.mParam value:param.mValue];
    }
}

- (void)resetSkinParams
{
    self.skinParams = [self originSkinParams];
    for (NETSBeautyParam *param in self.skinParams) {
        [self setBeautyParam:param];
    }
}

- (void)setFilterParam:(NETSBeautyParam *)param
{
    int handle = items[NETSFUNamaHandleTypeBeauty];
    [FURenderer itemSetParam:handle withName:@"filter_name" value:[param.mParam lowercaseString]];
    [FURenderer itemSetParam:handle withName:@"filter_level" value:@(param.mValue)]; //滤镜程度
    
    self.seletedFliter = param;
}

- (void)resetFilters
{
    self.filters = [self originFilters];
    self.seletedFliter = [self.filters firstObject];
    
    [self setFilterParam:self.seletedFliter];
}

- (void)setDefaultRotationMode:(int)mode
{
    fuSetDefaultRotationMode(mode);
}

- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    CVPixelBufferRef buffer = [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer withFrameId:frameID items:items itemCount:sizeof(items)/sizeof(int) flipx:YES]; // flipx 参数设为YES可以使道具做水平方向的镜像翻转
    frameID += 1;
    
    return buffer;
}

- (NSArray<NETSBeautyParam *> *)originFilters
{
    NSArray *beautyFiltersDataSource = @[@"origin",@"ziran1",@"ziran2",@"ziran3",@"ziran4",@"ziran5",@"ziran6",@"ziran7",@"ziran8",
    @"zhiganhui1",@"zhiganhui2",@"zhiganhui3",@"zhiganhui4",@"zhiganhui5",@"zhiganhui6",@"zhiganhui7",@"zhiganhui8",
                                          @"mitao1",@"mitao2",@"mitao3",@"mitao4",@"mitao5",@"mitao6",@"mitao7",@"mitao8",
                                         @"bailiang1",@"bailiang2",@"bailiang3",@"bailiang4",@"bailiang5",@"bailiang6",@"bailiang7"
                                         ,@"fennen1",@"fennen2",@"fennen3",@"fennen5",@"fennen6",@"fennen7",@"fennen8",
                                         @"lengsediao1",@"lengsediao2",@"lengsediao3",@"lengsediao4",@"lengsediao7",@"lengsediao8",@"lengsediao11",
                                         @"nuansediao1",@"nuansediao2",
                                         @"gexing1",@"gexing2",@"gexing3",@"gexing4",@"gexing5",@"gexing7",@"gexing10",@"gexing11",
                                         @"xiaoqingxin1",@"xiaoqingxin3",@"xiaoqingxin4",@"xiaoqingxin6",
                                         @"heibai1",@"heibai2",@"heibai3",@"heibai4"];
    
    NSDictionary *filtersCHName = @{@"origin":NSLocalizedString(@"原图", nil),@"bailiang1":NSLocalizedString(@"白亮1", nil),@"bailiang2":NSLocalizedString(@"白亮2", nil),@"bailiang3":NSLocalizedString(@"白亮3", nil),@"bailiang4":NSLocalizedString(@"白亮4", nil),@"bailiang5":NSLocalizedString(@"白亮5", nil),@"bailiang6":NSLocalizedString(@"白亮6", nil),@"bailiang7":NSLocalizedString(@"白亮7", nil)
                                    ,@"fennen1":NSLocalizedString(@"粉嫩1", nil),@"fennen2":NSLocalizedString(@"粉嫩2", nil),@"fennen3":NSLocalizedString(@"粉嫩3", nil),@"fennen4":NSLocalizedString(@"粉嫩4", nil),@"fennen5":NSLocalizedString(@"粉嫩5", nil),@"fennen6":NSLocalizedString(@"粉嫩6", nil),@"fennen7":NSLocalizedString(@"粉嫩7", nil),@"fennen8":NSLocalizedString(@"粉嫩8", nil),
                                    @"gexing1":NSLocalizedString(@"个性1", nil),@"gexing2":NSLocalizedString(@"个性2", nil),@"gexing3":NSLocalizedString(@"个性3", nil),@"gexing4":NSLocalizedString(@"个性4", nil),@"gexing5":NSLocalizedString(@"个性5", nil),@"gexing6":NSLocalizedString(@"个性6", nil),@"gexing7":NSLocalizedString(@"个性7", nil),@"gexing8":NSLocalizedString(@"个性8", nil),@"gexing9":NSLocalizedString(@"个性9", nil),@"gexing10":NSLocalizedString(@"个性10", nil),@"gexing11":NSLocalizedString(@"个性11", nil),
                                    @"heibai1":NSLocalizedString(@"黑白1", nil),@"heibai2":NSLocalizedString(@"黑白2", nil),@"heibai3":NSLocalizedString(@"黑白3", nil),@"heibai4":NSLocalizedString(@"黑白4", nil),@"heibai5":NSLocalizedString(@"黑白5", nil),
                                    @"lengsediao1":NSLocalizedString(@"冷色调1", nil),@"lengsediao2":NSLocalizedString(@"冷色调2", nil),@"lengsediao3":NSLocalizedString(@"冷色调3", nil),@"lengsediao4":NSLocalizedString(@"冷色调4", nil),@"lengsediao5":NSLocalizedString(@"冷色调5", nil),@"lengsediao6":NSLocalizedString(@"冷色调6", nil),@"lengsediao7":NSLocalizedString(@"冷色调7", nil),@"lengsediao8":NSLocalizedString(@"冷色调8", nil),@"lengsediao9":NSLocalizedString(@"冷色调9", nil),@"lengsediao10":NSLocalizedString(@"冷色调10", nil),@"lengsediao11":NSLocalizedString(@"冷色调11", nil),
                                    @"nuansediao1":NSLocalizedString(@"暖色调1", nil),@"nuansediao2":NSLocalizedString(@"暖色调2", nil),@"nuansediao3":NSLocalizedString(@"暖色调3", nil),@"xiaoqingxin1":NSLocalizedString(@"小清新1", nil),@"xiaoqingxin2":NSLocalizedString(@"小清新2", nil),@"xiaoqingxin3":NSLocalizedString(@"小清新3", nil),@"xiaoqingxin4":NSLocalizedString(@"小清新4", nil),@"xiaoqingxin5":NSLocalizedString(@"小清新5", nil),@"xiaoqingxin6":NSLocalizedString(@"小清新6", nil),
                                    @"ziran1":NSLocalizedString(@"自然1", nil),@"ziran2":NSLocalizedString(@"自然2", nil),@"ziran3":NSLocalizedString(@"自然3", nil),@"ziran4":NSLocalizedString(@"自然4", nil),@"ziran5":NSLocalizedString(@"自然5", nil),@"ziran6":NSLocalizedString(@"自然6", nil),@"ziran7":NSLocalizedString(@"自然7", nil),@"ziran8":NSLocalizedString(@"自然8", nil),
                                    @"mitao1":NSLocalizedString(@"蜜桃1", nil),@"mitao2":NSLocalizedString(@"蜜桃2", nil),@"mitao3":NSLocalizedString(@"蜜桃3", nil),@"mitao4":NSLocalizedString(@"蜜桃4", nil),@"mitao5":NSLocalizedString(@"蜜桃5", nil),@"mitao6":NSLocalizedString(@"蜜桃6", nil),@"mitao7":NSLocalizedString(@"蜜桃7", nil),@"mitao8":NSLocalizedString(@"蜜桃8", nil),
                                    @"zhiganhui1":NSLocalizedString(@"质感灰1", nil),@"zhiganhui2":NSLocalizedString(@"质感灰2", nil),@"zhiganhui3":NSLocalizedString(@"质感灰3", nil),@"zhiganhui4":NSLocalizedString(@"质感灰4", nil),@"zhiganhui5":NSLocalizedString(@"质感灰5", nil),@"zhiganhui6":NSLocalizedString(@"质感灰6", nil),@"zhiganhui7":NSLocalizedString(@"质感灰7", nil),@"zhiganhui8":NSLocalizedString(@"质感灰8", nil)
    };
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSString *str in beautyFiltersDataSource) {
        NETSBeautyParam *modle = [[NETSBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = [filtersCHName valueForKey:str];
        modle.mValue = 0.4;

        [temp addObject:modle];
    }
    return [temp copy];
}

- (NSArray<NETSBeautyParam *> *)originSkinParams
{
    NSArray *prams = @[@"color_level", @"blur_level", @"cheek_thinning", @"eye_enlarging"];
    NSDictionary *titelDic = @{@"color_level":NSLocalizedString(@"美白", nil), @"blur_level":NSLocalizedString(@"磨皮", nil), @"cheek_thinning":NSLocalizedString(@"瘦脸", nil), @"eye_enlarging":NSLocalizedString(@"大眼", nil)};
    NSDictionary *defaultValueDic = @{@"color_level":@(0.3), @"blur_level":@(0.7), @"cheek_thinning":@(0), @"eye_enlarging":@(0.4)};
    NSDictionary *minValArr = @{@"color_level":@(0.0), @"blur_level":@(0.0), @"cheek_thinning":@(0.0), @"eye_enlarging":@(0.0)};
    NSDictionary *maxValArr = @{@"color_level":@(2.0), @"blur_level":@(1.0), @"cheek_thinning":@(1.0), @"eye_enlarging":@(1.0)};
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSString *str in prams) {
        NETSBeautyParam *modle = [[NETSBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = [titelDic valueForKey:str];
        modle.mValue = [[defaultValueDic valueForKey:str] floatValue];
        modle.minVal = [[minValArr valueForKey:str] floatValue];
        modle.maxVal = [[maxValArr valueForKey:str] floatValue];
        modle.defaultValue = modle.mValue;
        [temp addObject:modle];
    }
    return [temp copy];
}

- (BOOL)isTracking
{
    return [FURenderer isTracking] > 0;
}

@end
