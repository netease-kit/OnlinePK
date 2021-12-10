//
//  NEPkServiceProtocol.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/16.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NEPkServiceProtocol <NSObject>
/// 收到PK请求
- (void)onPkRequestReceived;

/// PK请求被拒绝
- (void)onPkRequestRejected;

/// PK请求被取消
- (void)onPkRequestCancel;

/// PK请求被接受
- (void)onPkRequestAccept;

/// PK请求超时未响应
- (void)onPkRequestTimeout;

/// 开始PK
- (void)onPkStart;

/// 开始惩罚阶段
- (void)onPunishStart;

/// pk结束
- (void)onPkEnd;

@end

NS_ASSUME_NONNULL_END
