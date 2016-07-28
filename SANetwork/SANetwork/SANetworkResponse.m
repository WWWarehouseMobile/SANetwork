//
//  SANetworkResponse.m
//  ECM
//
//  Created by 学宝 on 16/1/16.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkResponse.h"
#import "SANetworkConfig.h"

@interface SANetworkResponse ()

@property (nonatomic, copy) id responseData;
@property (nonatomic, assign, readwrite) SANetworkStatus networkStatus;
@property (nonatomic, assign, readwrite) NSInteger requestTag;
@property (nonatomic, assign, readwrite) BOOL isCache;

@property (nonatomic, copy, readwrite) NSString *responseMessage;

@property (nonatomic, copy, readwrite) id responseContentData;
@property (nonatomic, assign, readwrite) NSInteger responseCode;


@end

@implementation SANetworkResponse

- (instancetype)initWithResponseData:(id)responseData requestTag:(NSInteger)requestTag networkStatus:(SANetworkStatus)networkStatus {
    self = [super init];
    if (self) {
        _responseData = responseData;
        _requestTag = requestTag;
        _isCache = networkStatus == SANetworkResponseDataCacheStatus ? YES:NO;
        _networkStatus = networkStatus;
        
        _responseCode = NSNotFound;
        switch (networkStatus) {
            case SANetworkResponseDataSuccessStatus:
            case SANetworkResponseDataCacheStatus:
            case SANetworkResponseDataIncorrectStatus:{
                if ([responseData isKindOfClass:[NSDictionary class]]) {
                    if ([SANetworkConfig sharedInstance].responseCodeKey && responseData[[SANetworkConfig sharedInstance].responseCodeKey]) {
                        _responseCode = [responseData[[SANetworkConfig sharedInstance].responseCodeKey] integerValue];
                    }
                    if ([SANetworkConfig sharedInstance].responseMessageKey) {
                        _responseMessage = responseData[[SANetworkConfig sharedInstance].responseMessageKey];
                    }
                    if ([SANetworkConfig sharedInstance].responseContentDataKey) {
                        _responseContentData = responseData[[SANetworkConfig sharedInstance].responseContentDataKey];
                    }
                }
            }
                break;
            default:
                _responseMessage = [self responseMsgByNetworkStatus:networkStatus];
                break;
        }
        
        
    }
    return self;
}

- (id)fetchDataWithReformer:(id<SANetworkResponseReformerProtocol>)reformer {
    if ([reformer respondsToSelector:@selector(networkResponse:reformerDataWithOriginData:)]) {
        return [reformer networkResponse:self reformerDataWithOriginData:self.responseData];
    }
    return [self.responseData mutableCopy];
}

- (NSString *)responseMsgByNetworkStatus:(SANetworkStatus)networkStatus {
    /**
     *  @brief     若做国际化的话，因为AFNetworking的国际化文件使用的是AFNetworking.strings，这个类库又是依赖AFNetworking的。为了少创建一个 .strings 文件。这里就复用“AFNetworking”了。
     */
    switch (networkStatus) {
        case SANetworkNotReachableStatus:
            return NSLocalizedStringFromTable(@"暂无网络连接", @"AFNetworking", nil);
        case SANetworkResponseDataAuthenticationFailStatus:
            return NSLocalizedStringFromTable(@"数据验证失败", @"AFNetworking", nil);
        case SANetworkRequestParamIncorrectStatus:
            return NSLocalizedStringFromTable(@"请求参数有误", @"AFNetworking", nil);
        case SANetworkResponseFailureStatus:
            return NSLocalizedStringFromTable(@"请求数据失败", @"AFNetworking", nil);
        default:
            return nil;
    }
}

@end
