//
//  NETSConnectMicModel.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/14.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSConnectMicModel.h"


@implementation NETSConnectMicMemberModel

- (NSDictionary *)getConnectMicMemberDictionary {

    return @{
                  @"accountId": self.accountId ?:@"",
                  @"avRoomUid": self.avRoomUid ?:@"",
                  @"avRoomCid":self.avRoomCid ?:@"",
                @"avRoomCName": self.avRoomCName ?:@"",
             @"avRoomCheckSum": self.avRoomCheckSum ?:@"",
                   @"nickName": self.nickName ?:@"",
                    @"avatar": self.avatar ?:@"",
                     @"audio": @(self.audio),
                     @"video": @(self.video)
              };
    
}
@end

@implementation NETSConnectMicModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{@"member" : [NETSConnectMicMemberModel class]};
}

@end




