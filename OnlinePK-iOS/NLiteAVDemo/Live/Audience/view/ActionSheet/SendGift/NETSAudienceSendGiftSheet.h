//
//  NETSAudienceSendGiftSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSBaseActionSheet.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSGiftModel, NETSAudienceSendGiftSheet;

@protocol NETSAudienceSendGiftSheetDelegate <NSObject>

- (void)didSendGift:(NETSGiftModel *)gift onSheet:(NETSAudienceSendGiftSheet *)sheet;

@end

@interface NETSAudienceSendGiftSheet : NETSBaseActionSheet

+ (void)showWithTarget:(id<NETSAudienceSendGiftSheetDelegate>)target gifts:(NSArray<NETSGiftModel *> *)gifts;

@end

NS_ASSUME_NONNULL_END
