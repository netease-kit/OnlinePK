//
//  NEPkPassthroughService.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/17.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPkPassthroughService.h"
#import "SKVObject.h"
#import "TopmostView.h"
#import "NETSLiveApi.h"
#import "AppKey.h"
#import "NETSFUManger.h"
#import "NETSAudienceCollectionViewVC.h"
#import "NENavigator.h"

#import "NEPassthroughPkInviteModel.h"


@implementation NEPkPassthroughService

//收到的透传代理
-(void)didReceivedPassThroughMsg:(NIMPassThroughMsgData *)recvData {
    
    NSString *body = recvData.body;
    if (isEmptyString(body)) { return; }
    
    SKVObject *obj = [SKVObject ofJSON:body];
    if (!obj) { return; }
    
    NSDictionary *dataDic = [obj dictionaryValue];
    if (!dataDic) { return; }
    
    NSInteger type = [dataDic[@"type"] integerValue];
//    NSDictionary * dataDic = dict[@"data"];
//    if (!dataDic) { return; }

    switch (type) {
            
        case NEPKChatRoomMessageBodyPkInvite:{
            
            NEPkOperation  operationAction = [dataDic[@"action"] integerValue];
            NEPassthroughPkInviteModel *inviteActionModel = [NEPassthroughPkInviteModel yy_modelWithDictionary:dataDic];
            
            if (operationAction == NEPkOperationInvite) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhPKInviteData:)]) {
                    [self.delegate receivePassThrourhPKInviteData:inviteActionModel];
                }
            }else if (operationAction == NEPkOperationAgree) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhAgreePkData:)]) {
                    [self.delegate receivePassThrourhAgreePkData:inviteActionModel];
                }
            }else if (operationAction == NEPkOperationRefuse) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhRefusePKInviteData:)]) {
                    [self.delegate receivePassThrourhRefusePKInviteData:inviteActionModel];
                }
            }else if (operationAction == NEPkOperationCancel) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhCancelPKInviteData:)]) {
                    [self.delegate receivePassThrourhCancelPKInviteData:inviteActionModel];
                }
            }else if (operationAction == NEPkOperationTimeout) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhTimeOutData:)]) {
                    [self.delegate receivePassThrourhTimeOutData:inviteActionModel];
                }
            }
        }
            break;

        default:
            break;
    }
}

@end
