//
//  SANetworkResponse.m
//  ECM
//
//  Created by 学宝 on 16/1/16.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkResponse.h"
#import <YYModel/NSObject+YYModel.h>

@interface SANetworkResponse ()


@property (nonatomic, copy) id responseData;

@property (nonatomic, assign, readwrite) NSInteger requestTag;

@property (nonatomic, assign, readwrite) BOOL isCache;

@property (nonatomic, assign, readwrite) SANetworkResponseStatus networkResponseStatus;

@property (nonatomic, copy, readwrite) NSObject *contentData;

@property (nonatomic, copy, readwrite) NSString *message;

@property (nonatomic, assign, readwrite) NSInteger code;


@end

static NSString *kResponseCodeKey = nil;
static NSString *kResponseMessageKey = nil;
static NSString *kResponseContentDataKey = nil;

@implementation SANetworkResponse

- (instancetype)initWithResponseData:(id)responseData responseModelClass:(Class)responseModelClass requestTag:(NSInteger)requestTag networkResponseStatus:(SANetworkResponseStatus)networkResponseStatus{
    self = [super init];
    if (self) {
        _responseData = responseData;
        _requestTag = requestTag;
        _isCache = networkResponseStatus== SANetworkResponseCacheStatus ? YES:NO;
        _networkResponseStatus = networkResponseStatus;
        
        if (kResponseCodeKey) {
            _code = [responseData[kResponseCodeKey] integerValue];
        }else{
            _code = NSNotFound;
        }
        if (kResponseMessageKey) {
            switch (networkResponseStatus) {
                case SANetworkResponseSuccessStatus:
                case SANetworkResponseCacheStatus:
                case SANetworkResponseIncorrectStatus:
                    _message = responseData[kResponseMessageKey];
                    break;
                case SANetworkResponseAuthenticationFailStatus:
                    _message = @"数据验证失败 !";
                    break;
                default:
                    _message = @"请求数据失败";
                    break;
            }
        }
        if ((networkResponseStatus == SANetworkResponseCacheStatus || networkResponseStatus == SANetworkResponseSuccessStatus) && kResponseContentDataKey) {
            _contentData = responseData[kResponseContentDataKey];
            if (responseModelClass != Nil) {
                if ([_contentData isKindOfClass:[NSDictionary class]]) {
                    _contentData = [responseModelClass yy_modelWithDictionary:(NSDictionary *)_contentData];
                }else if ([_contentData isKindOfClass:[NSArray class]]){
                    _contentData = [NSArray yy_modelArrayWithClass:responseModelClass json:_contentData];
                }
            }

        }
        
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

- (id)fetchDataWithReformer:(id<SANetworkResponseReformerProtocol>)reformer {
    if ([reformer respondsToSelector:@selector(networkResponse:reformerDataWithOriginData:)]) {
        return [reformer networkResponse:self reformerDataWithOriginData:self.responseData];
    }
    return [self.contentData mutableCopy];
}


@end
