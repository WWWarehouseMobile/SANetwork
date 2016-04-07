//
//  SANetworkResponse.m
//  ECM
//
//  Created by 学宝 on 16/1/16.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkResponse.h"

@interface SANetworkResponse ()

@property (nonatomic, copy, readwrite) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, copy) id responseData;

@property (nonatomic, assign, readwrite) NSInteger requestTag;

@property (nonatomic, assign, readwrite) BOOL isCache;

@property (nonatomic, assign, readwrite) SANetworkStatus networkStatus;
@end

static NSString *kResponseCodeKey = nil;
static NSString *kResponseMessageKey = nil;
static NSString *kResponseContentDataKey = nil;

@implementation SANetworkResponse

- (instancetype)initWithResponse:(id)response sessionDataTask:(NSURLSessionDataTask *)sessionDataTask requestTag:(NSInteger)requestTag networkStatus:(SANetworkStatus)networkStatus{
    self = [super init];
    if (self) {
        _responseData = response;
        _sessionDataTask = sessionDataTask;
        _requestTag = requestTag;
        _isCache = networkStatus== SANetworkStatusCache ? YES:NO;
        _networkStatus = networkStatus;
    }
    return self;
}

+ (void)setResponseCodeKey:(NSString *)codeKey {
    kResponseCodeKey = codeKey;
}

+ (void)setResponseContentDataKey:(NSString *)contentDataKey {
    kResponseContentDataKey = contentDataKey;
}

+ (void)setResponseMessageKey:(NSString *)messageKey {
    kResponseMessageKey = messageKey;
}

- (id)contentData {
    if (kResponseContentDataKey) {
        return self.responseData[kResponseContentDataKey];
    }
    return @"请设置responseCodeKey";
}

- (NSString *)message {
    if (kResponseMessageKey) {
        if (self.networkStatus == SANetworkStatusResponseDataFailAuthentication) {
            return @"数据验证失败 !";
        }
        return self.responseData[kResponseMessageKey];
    }
    return @"请设置responseMessageKey";
}

- (NSInteger)code {
    if (kResponseCodeKey) {
        return [self.responseData[kResponseCodeKey] integerValue];
    }
    return NSNotFound;
}


- (id)fetchDataWithReformer:(id<SANetworkResponseReformerProtocol>)reformer {
    if ([reformer respondsToSelector:@selector(networkResponse:reformerDataWithOriginData:)]) {
        return [reformer networkResponse:self reformerDataWithOriginData:self.contentData];
    }
    return [self.contentData mutableCopy];
}


@end
