//
//  NELiveRoomDelegateProxy.m
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/10.
//  Copyright © 2021 NetEase. All rights reserved.
//

#import "NELiveRoomDelegateProxy.h"

@interface NELiveRoomDelegateProxy ()

/// 弱引用集合
@property (nonatomic, strong) NSHashTable *weakDelegates;

/// lock
@property (nonatomic, strong) NSLock *lock;

@end

@implementation NELiveRoomDelegateProxy

- (instancetype)init {
    self.lock = NSLock.new;
    self.weakDelegates = NSHashTable.weakObjectsHashTable;
    return self;
}

+ (instancetype)sharedProxy {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return YES;
}

- (BOOL)isProxy {
    return YES;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return YES;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    [self.lock lock];
    NSArray *allDelegates = self.weakDelegates.allObjects;
    NSMethodSignature *sig;
    for (NSObject *delegate in allDelegates) {
        sig = [delegate methodSignatureForSelector:sel];
        if (sig) {
            break;
        }
    }
    [self.lock unlock];
    return sig ?: [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self.lock lock];
    NSArray *allDelegates = self.weakDelegates.allObjects;
    for (id delegate in allDelegates) {
        if ([delegate respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegate];
        } else {
            invocation.target = nil;
            [invocation invoke];
        }
    }
    [self.lock unlock];
}

- (void)addDelegate:(id)delegate {
    [self.lock lock];
    [self.weakDelegates addObject:delegate];
    [self.lock unlock];
}

- (void)removeDelegate:(id)delegate {
    [self.lock lock];
    [self.weakDelegates removeObject:delegate];
    [self.lock unlock];
}

@end
