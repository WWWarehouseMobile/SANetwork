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

@property (nonatomic, copy, readwrite) id contentData;

@property (nonatomic, copy, readwrite) NSString *message;

@property (nonatomic, assign, readwrite) NSInteger requestTag;

@property (nonatomic, assign, readwrite) BOOL isCache;

@property (nonatomic, assign, readwrite) SANetworkStatus networkStatus;
@end

@implementation SANetworkResponse

- (instancetype)initWithResponse:(id)response sessionDataTask:(NSURLSessionDataTask *)sessionDataTask requestTag:(NSInteger)requestTag networkStatus:(SANetworkStatus)networkStatus{
    self = [super init];
    if (self) {
        //或等待具体服务端 返回定制不同的属性值
        _contentData = response[@"content"];
        if (response[@"msg"] != nil) {
            _message = response[@"msg"];
        }
        _sessionDataTask = sessionDataTask;
        _requestTag = requestTag;
        _isCache = networkStatus== SANetworkStatusCache ? YES:NO;
        _networkStatus = networkStatus;
    }
    return self;
}

- (id)fetchDataWithReformer:(id<SANetworkResponseReformerProtocol>)reformer {
    if ([reformer respondsToSelector:@selector(networkResponse:reformerDataWithOriginData:)]) {
        return [reformer networkResponse:self reformerDataWithOriginData:self.contentData];
    }
    return [self.contentData mutableCopy];
}
@end
