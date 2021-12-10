//
//  NELiveRoomURLProtocol.m
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/31.
//

#import "NELiveRoomURLProtocol.h"
#import "NESeatConsts.h"
#import <NELiveRoom/NELiveRoom-Swift.h>

@implementation NELiveRoomURLProtocol

+ (void)load {
    [NSURLProtocol registerClass:self];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *host = NELiveRoom.sharedSDK.baseURL.host;
    NSAssert(host, @"ApiHost未填写!");
    BOOL shouldAccept = [request.URL.host isEqualToString:host];
    return shouldAccept;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSString *appKey = NELiveRoom.sharedSDK.options.appKey;
    NSAssert(appKey.length, @"AppKey未填写!");
    NSMutableURLRequest *mutableRequest = request.mutableCopy;
    [mutableRequest setValue:appKey forHTTPHeaderField:@"appKey"];
    [mutableRequest setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    return mutableRequest;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (![response isKindOfClass:NSHTTPURLResponse.class]) {
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NESeatErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey: @"Response is not NSHTTPURLResponse!!"}]];
        completionHandler(NSURLSessionResponseAllow);
        return;
    }
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    if (resp.statusCode != 200) {
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:resp.statusCode userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Status is %@", @(resp.statusCode)]}]];
        completionHandler(NSURLSessionResponseAllow);
        return;
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!data.length) {
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NESeatErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:nil]];
        return;
    }
    NSError *error;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NESeatErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:@{NSLocalizedDescriptionKey: error.localizedDescription}]];
        return;
    }
    NSInteger code = [response[@"code"] integerValue];
    if (code != 200) {
        NSString *message = response[@"message"] ?: @"";
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NESeatErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: message}]];
        return;
    }
#if DEBUG
    NSString *requestId = response[@"requestId"];
    NSNumber *costTime = response[@"costTime"];
    NSLog(@"request %@ cost time %@", requestId, costTime);
#endif
    if (!response[@"data"]) {
        [self.client URLProtocol:self didLoadData:[NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil]];
        return;
    }
    if ([NSJSONSerialization isValidJSONObject:response[@"data"]]) {
        data = [NSJSONSerialization dataWithJSONObject:response[@"data"] options:0 error:nil];
    } else {
        data = [NSJSONSerialization dataWithJSONObject:@{@"data": response[@"data"]} options:0 error:nil];
    }
    [self.client URLProtocol:self didLoadData:data];
}

@end
