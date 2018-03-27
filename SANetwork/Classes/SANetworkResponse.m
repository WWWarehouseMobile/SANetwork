//
//  SANetworkResponse.m
//  ECM
//
//  Created by 学宝 on 16/1/16.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import "SANetworkResponse.h"
#import "SANetworkConfig.h"
#import "SANetworkServiceProtocol.h"

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

- (instancetype)initWithResponseData:(id)responseData serviceIdentifierKey:(NSString *)serviceIdentifierKey requestTag:(NSInteger)requestTag networkStatus:(SANetworkStatus)networkStatus {
    self = [super init];
    if (self) {
        _responseData = responseData;
        _requestTag = requestTag;
        _networkStatus = networkStatus;
        
        _responseCode = NSNotFound;
        switch (networkStatus) {
            case SANetworkResponseDataSuccessStatus:
            case SANetworkResponseDataIncorrectStatus:
            case SANetworkResponseDataAuthenticationFailStatus:{
                NSObject<SANetworkServiceProtocol> *serviceObject = [[SANetworkConfig sharedInstance] serviceObjectWithServiceIdentifier:serviceIdentifierKey];
                if ([responseData isKindOfClass:[NSDictionary class]]) {
                    if ([serviceObject respondsToSelector:@selector(responseCodeKey)]) {
                        _responseCode = [responseData[[serviceObject responseCodeKey]] integerValue];
                    }
                    if ([serviceObject respondsToSelector:@selector(responseMessageKey)]) {
                        _responseMessage = responseData[[serviceObject responseMessageKey]];
                    }
                    if ([serviceObject respondsToSelector:@selector(responseContentDataKey)]) {
                        _responseContentData = responseData[[serviceObject responseContentDataKey]];
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
            return NSLocalizedStringFromTable(@"网络异常", @"AFNetworking", nil);
        case SANetworkRequestParamIncorrectStatus:
            return NSLocalizedStringFromTable(@"请求参数有误", @"AFNetworking", nil);
        case SANetworkResponseFailureStatus:
            return NSLocalizedStringFromTable(@"系统异常", @"AFNetworking", nil);
        default:
            return nil;
    }
}

@end
