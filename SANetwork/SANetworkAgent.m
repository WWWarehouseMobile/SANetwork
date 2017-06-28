//
//  SANetworkAgent.m
//  ECM
//
//  Created by 学宝 on 16/1/13.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkAgent.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFNetworking/AFNetworking.h>

#import "SANetworkConfig.h"
#import "SANetworkRequest.h"
#import "SANetworkResponse.h"
#import "SANetworkLogger.h"

@interface SANetworkAgent ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong) NSMutableDictionary <NSString*, __kindof SANetworkRequest*>*requestRecordDict;

@end

@implementation SANetworkAgent


+ (SANetworkAgent *)sharedInstance {
    static SANetworkAgent *networkAgentInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkAgentInstance = [[self alloc] init];
    });
    return networkAgentInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestRecordDict = [NSMutableDictionary dictionary];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.operationQueue.maxConcurrentOperationCount = 3;
        AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        jsonResponseSerializer.removesKeysWithNullValues = YES;
        _sessionManager.responseSerializer = jsonResponseSerializer;
    }
    return _sessionManager;
}

#pragma mark-
#pragma mark-Getter

- (NSObject<SANetworkServiceProtocol> *)serviceObjectByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    NSString *serviceKey = [request.requestConfigProtocol serviceIdentifierKey];
    NSAssert(serviceKey.length, @"你应该设置服务标示的key");
    NSObject<SANetworkServiceProtocol> *serviceObject = [[SANetworkConfig sharedInstance] serviceObjectWithServiceIdentifier:serviceKey];
    return serviceObject;
}

- (NSString *)urlStringByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    NSString *detailUrl = @"";
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethodName)]) {
        detailUrl = [request.requestConfigProtocol requestMethodName];
    }
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    
    NSString *serviceURLString = nil;

    serviceURLString = [[self serviceObjectByRequest:request] serviceApiBaseUrlString];
    if ([serviceURLString hasPrefix:@"http"]) {
        return [serviceURLString stringByAppendingPathComponent:detailUrl];
    }else {
        NSLog(@"\n\n\n请设置正确的URL\n\n\n");
        return nil;
    }
}

- (NSDictionary *)requestParamByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestParamDictionary)]) {
        NSDictionary *paramDict = [request.requestConfigProtocol requestParamDictionary];
        if (paramDict != nil) {
            [tempDict addEntriesFromDictionary:paramDict];
        }
    }
    
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseRequestParamSource)] || [request.requestConfigProtocol useBaseRequestParamSource])) {
        NSObject<SANetworkServiceProtocol> *serviceObject = [self serviceObjectByRequest:request];
        if ([serviceObject respondsToSelector:@selector(serviceBaseParamSource)]) {
            NSDictionary *baseRequestParamSource = [serviceObject serviceBaseParamSource];
            if (baseRequestParamSource != nil) {
                [tempDict addEntriesFromDictionary:baseRequestParamSource];
            }
        }

    }
    if (tempDict.count == 0) {
        return nil;
    }
    return [NSDictionary dictionaryWithDictionary:tempDict];
}

- (BOOL)isCorrectByRequestParams:(NSDictionary *)requestParams request:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(isCorrectWithRequestParams:)]) {
        return [request.requestConfigProtocol isCorrectWithRequestParams:requestParams];
    }
    return YES;
}

- (SARequestHandleSameRequestType)handleSameRequestTypeByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(handleSameRequestType)]) {
        return [request.requestConfigProtocol handleSameRequestType];
    }
    return SARequestHandleSameRequestCancelCurrentType;
}

- (SARequestMethod)requestMethodByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethod)]) {
        return [request.requestConfigProtocol requestMethod];
    }
    return SARequestMethodPost;
}

- (NSURLRequestCachePolicy)cachePolicyByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(cachePolicy)]) {
        NSURLRequestCachePolicy cachePolicy = [request.requestConfigProtocol cachePolicy];
        if (cachePolicy == NSURLRequestUseProtocolCachePolicy) {
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
                return NSURLRequestReturnCacheDataDontLoad;
            }
            return NSURLRequestUseProtocolCachePolicy;
        }
        return cachePolicy;
    }
    return NSURLRequestReloadIgnoringCacheData;
}


#pragma mark-
#pragma mark-Setter

- (void)setSessionManagerRequestSerializerByRequestSerializerType:(SARequestSerializerType)requestSerializerType {
    switch (requestSerializerType) {
        case SARequestSerializerTypeHTTP:
            self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        case SARequestSerializerTypeJSON:
            if (![self.sessionManager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]) {
                self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            }
            break;
        case SARequestSerializerTypePropertyList:
            if (![self.sessionManager.requestSerializer isKindOfClass:[AFPropertyListRequestSerializer class]]) {
                self.sessionManager.requestSerializer = [AFPropertyListRequestSerializer serializer];
            }
            break;
        default:
            break;
    }
    self.sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
}

- (void)setSessionManagerResponseSerializerByResponseSerializerType:(SAResponseSerializerType)responseSerializerType {
    switch (responseSerializerType) {
        case SAResponseSerializerTypeHTTP:
            self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case SAResponseSerializerTypeJSON:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
                AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
                jsonResponseSerializer.removesKeysWithNullValues = YES;
                self.sessionManager.responseSerializer = jsonResponseSerializer;
            }
            break;
        case SAResponseSerializerTypeImage:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFImageResponseSerializer class]]) {
                self.sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
            }
            break;
        case SAResponseSerializerTypeXMLParser:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFXMLParserResponseSerializer class]]) {
                self.sessionManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            }
            break;
        case SAResponseSerializerTypePropertyList:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFPropertyListResponseSerializer class]]) {
                self.sessionManager.responseSerializer = [AFPropertyListResponseSerializer serializer];
            }
            break;
        default:
            break;
    }

}

- (void)setupSessionManagerRequestSerializerByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    //配置requestSerializerType
    NSObject<SANetworkServiceProtocol> *serviceObject = [self serviceObjectByRequest:request];
    SARequestSerializerType requestSerializerType;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestSerializerType)]) {
        requestSerializerType = [request.requestConfigProtocol requestSerializerType];
    }else if([serviceObject respondsToSelector:@selector(serviceRequestSerializerType)]){
        requestSerializerType = [serviceObject serviceRequestSerializerType];
    }else {
        requestSerializerType = SARequestSerializerTypeHTTP;
    }
    [self setSessionManagerRequestSerializerByRequestSerializerType:requestSerializerType];
    
    //配置请求头
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseHTTPRequestHeaders)] || [request.requestConfigProtocol useBaseHTTPRequestHeaders])) {
        if ([[self serviceObjectByRequest:request] respondsToSelector:@selector(serviceBaseHTTPRequestHeaders)]) {
            NSDictionary *requestHeaders = [[self serviceObjectByRequest:request] serviceBaseHTTPRequestHeaders];
            [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    
    if ([request.requestConfigProtocol respondsToSelector:@selector(customHTTPRequestHeaders)]) {
        NSDictionary *customRequestHeaders = [request.requestConfigProtocol customHTTPRequestHeaders];
        [customRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    //配置请求超时时间
    NSTimeInterval timeoutInterval = 20.0f;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestTimeoutInterval)]) {
        timeoutInterval = [request.requestConfigProtocol requestTimeoutInterval];
    } else if ([serviceObject respondsToSelector:@selector(serviceRequestTimeoutInterval)]) {
        timeoutInterval = [serviceObject serviceRequestTimeoutInterval];
    }
    self.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
    
    //配置responseSerializerType
    SAResponseSerializerType responseSerializerType = SAResponseSerializerTypeJSON;
    if ([request.requestConfigProtocol respondsToSelector:@selector(responseSerializerType)]) {
        responseSerializerType = [request.requestConfigProtocol responseSerializerType];
    }else if ([serviceObject respondsToSelector:@selector(serviceResponseSerializerType)]){
        responseSerializerType = [serviceObject serviceResponseSerializerType];
    }
    [self setSessionManagerResponseSerializerByResponseSerializerType:responseSerializerType];
    
    if ([request.requestConfigProtocol respondsToSelector:@selector(responseAcceptableContentTypes)] && [request.requestConfigProtocol responseAcceptableContentTypes]) {
        self.sessionManager.responseSerializer.acceptableContentTypes = [request.requestConfigProtocol responseAcceptableContentTypes];
    } else {
        self.sessionManager.responseSerializer.acceptableContentTypes = [serviceObject serviceResponseAcceptableContentTypes];
    }
    
    //配置请求缓存策略
    self.sessionManager.requestSerializer.cachePolicy = [self cachePolicyByRequest:request];
}

- (AFConstructingBlock)constructingBlockByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(constructingBodyBlock)]) {
        return [request.requestConfigProtocol constructingBodyBlock];
    }
    return nil;
}
#pragma mark-
#pragma mark-处理Request

- (void)addRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    NSString *requestURLString = [self urlStringByRequest:request];
    NSDictionary *requestParam = [self requestParamByRequest:request];
    
    //检查参数配置
    if (![self isCorrectByRequestParams:requestParam request:request]) {
        NSLog(@"参数配置有误！请查看isCorrectWithRequestParams: !");
        [request stopRequestByStatus:SANetworkRequestParamIncorrectStatus];
        SANetworkResponse *paramIncorrectResponse = [[SANetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:[request serviceIdentifierKey] requestTag:request.tag networkStatus:SANetworkRequestParamIncorrectStatus];
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            [request.responseDelegate networkRequest:request failedByResponse:paramIncorrectResponse];
        }
        return;
    }
    
    SARequestHandleSameRequestType handleSameRequestType = [self handleSameRequestTypeByRequest:request];
    if (handleSameRequestType != SARequestHandleSameRequestBothContinueType) {
        //检查是否存在相同请求方法未完成，并根据协议接口决定是否结束之前的请求
        BOOL isContinuePerform = YES;
        for (SANetworkRequest<SANetworkRequestConfigProtocol> *requestingObj in self.requestRecordDict.allValues) {
            if ([[self urlStringByRequest:requestingObj] isEqualToString:requestURLString]) {
                switch (handleSameRequestType) {
                    case SARequestHandleSameRequestCancelCurrentType:
                        isContinuePerform = NO;
                        break;
                    case SARequestHandleSameRequestCancelPreviousType:
                        [requestingObj stopRequestByStatus:SANetworkRequestCancelStatus];
                        break;
                    default:
                        break;
                }
                break;
            }
        }
        
        if (isContinuePerform == NO){
            NSLog(@"有个相同URL请求未完成，这个请求被取消了（可设置handleSameRequestType）");
            [request stopRequestByStatus:SANetworkRequestCancelStatus];
            return;
        }
    }
    
    if ([request respondsToSelector:@selector(enableDebug)]) {
        if ([request enableDebugLog]) {
            [SANetworkLogger logDebugRequestInfoWithURL:requestURLString httpMethod:[self requestMethodByRequest:request] params:requestParam reachabilityStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]];
        }
    }else if ([SANetworkConfig sharedInstance].enableDebug) {
        [SANetworkLogger logDebugRequestInfoWithURL:requestURLString httpMethod:[self requestMethodByRequest:request] params:requestParam reachabilityStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]];
    }
    
    __weak typeof(self)weakSelf = self;
    [self setupSessionManagerRequestSerializerByRequest:request];
    __block SANetworkRequest<SANetworkRequestConfigProtocol> *blockRequest = request;
    switch ([self requestMethodByRequest:request]) {
        case SARequestMethodGet:{
            request.sessionDataTask = [self.sessionManager GET:requestURLString
                                                    parameters:requestParam
                                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                                          [weakSelf handleRequestProgress:downloadProgress request:blockRequest];
                                                      }
                                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                           [weakSelf handleRequestSuccess:task responseObject:responseObject];
                                                       }
                                                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                           [weakSelf handleRequestFailure:task error:error];
                                                       }];
        }
            break;
        case SARequestMethodPost:{
            AFConstructingBlock constructingBlock = [self constructingBlockByRequest:request];
            if (constructingBlock) {
                request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                         parameters:requestParam
                                          constructingBodyWithBlock:constructingBlock
                                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                                               [weakSelf handleRequestProgress:uploadProgress request:blockRequest];
                                                           }
                                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [weakSelf handleRequestSuccess:task responseObject:responseObject];
                                                            }
                                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [weakSelf handleRequestFailure:task error:error];
                                                            }];
            }else{
                request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                         parameters:requestParam
                                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                                               [weakSelf handleRequestProgress:uploadProgress request:blockRequest];
                                                           }
                                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [weakSelf handleRequestSuccess:task responseObject:responseObject];
                                                            }
                                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [weakSelf handleRequestFailure:task error:error];
                                                            }];
            }
        }
            break;
        default:
            break;
    }
    [self addRequestObject:request];
    
}

- (void)removeRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if(request.sessionDataTask == nil)  return;
    
    [request.sessionDataTask cancel];
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        [_requestRecordDict removeObjectForKey:taskKey];
    }
}

#pragma mark-
#pragma mark-处理请求响应结果

- (void)beforePerformFailWithResponse:(SANetworkResponse *)response request:(SANetworkRequest *)request{
    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:beforePerformFailWithResponse:)]) {
        [request.interceptorDelegate networkRequest:request beforePerformFailWithResponse:response];
    }
}
- (void)afterPerformFailWithResponse:(SANetworkResponse *)response request:(SANetworkRequest *)request{
    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:afterPerformFailWithResponse:)]) {
        [request.interceptorDelegate networkRequest:request afterPerformFailWithResponse:response];
    }
}

- (void)handleRequestProgress:(NSProgress *)progress request:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:requestingByProgress:)]) {
        [request.responseDelegate networkRequest:request requestingByProgress:progress];
    }
}

- (void)handleRequestSuccess:(NSURLSessionDataTask *)sessionDataTask responseObject:(id)response {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    SANetworkRequest<SANetworkRequestConfigProtocol> *request = _requestRecordDict[taskKey];
    if (request == nil){
        NSLog(@"请求实例被意外释放!");
        return;
    }
    BOOL isAuthentication = YES;
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseAuthentication)] || [request.requestConfigProtocol useBaseAuthentication])) {
        NSObject<SANetworkServiceProtocol> *serviceObject = [self serviceObjectByRequest:request];
        if ([serviceObject respondsToSelector:@selector(serviceBaseAuthenticationWithNetworkRequest:response:)]) {
            isAuthentication = [serviceObject serviceBaseAuthenticationWithNetworkRequest:request response:response];
        }
    }
    if(isAuthentication && [request.requestConfigProtocol isCorrectWithResponseData:response]){
        [request stopRequestByStatus:SANetworkResponseDataSuccessStatus];
        SANetworkResponse *successResponse = [[SANetworkResponse alloc] initWithResponseData:response serviceIdentifierKey:[request serviceIdentifierKey] requestTag:request.tag networkStatus:SANetworkResponseDataSuccessStatus];
        if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:beforePerformSuccessWithResponse:)]) {
            [request.interceptorDelegate networkRequest:request beforePerformSuccessWithResponse:response];
        }
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            [request.responseDelegate networkRequest:request succeedByResponse:successResponse];
        }
        if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:afterPerformSuccessWithResponse:)]) {
            [request.interceptorDelegate networkRequest:request afterPerformSuccessWithResponse:response];
        }
    } else {
        SANetworkStatus failStatus = isAuthentication ? SANetworkResponseDataIncorrectStatus : SANetworkResponseDataAuthenticationFailStatus;
        [request stopRequestByStatus:failStatus];
        SANetworkResponse *dataErrorResponse = [[SANetworkResponse alloc] initWithResponseData:response serviceIdentifierKey:[request serviceIdentifierKey] requestTag:request.tag networkStatus:failStatus];
        [self beforePerformFailWithResponse:dataErrorResponse request:request];
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            [request.responseDelegate networkRequest:request failedByResponse:dataErrorResponse];
        }
        [self afterPerformFailWithResponse:dataErrorResponse request:request];
    }
    
    if ([request respondsToSelector:@selector(enableDebug)]) {
        if ([request enableDebugLog]) {
            [SANetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:response authentication:isAuthentication error:nil];
        }
    }else if ([SANetworkConfig sharedInstance].enableDebug) {
        [SANetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:response authentication:isAuthentication error:nil];
    }
}

- (void)handleRequestFailure:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    SANetworkRequest<SANetworkRequestConfigProtocol> *request = _requestRecordDict[taskKey];
    SANetworkStatus failStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable ? SANetworkNotReachableStatus : SANetworkResponseFailureStatus;
    [request stopRequestByStatus:failStatus];
    if (request == nil) {
        NSLog(@"请求实例被意外释放!");
        return;
    }
    SANetworkResponse *failureResponse = [[SANetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:[request serviceIdentifierKey] requestTag:request.tag networkStatus:failStatus];
    [self beforePerformFailWithResponse:failureResponse request:request];
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
        [request.responseDelegate networkRequest:request failedByResponse:failureResponse];
    }
    [self afterPerformFailWithResponse:failureResponse request:request];
    
    if ([request respondsToSelector:@selector(enableDebug)]) {
        if ([request enableDebugLog]) {
            [SANetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:nil authentication:NO error:error];
        }
    }else if ([SANetworkConfig sharedInstance].enableDebug) {
        [SANetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:nil authentication:NO error:error];
    }
}

#pragma mark-
#pragma mark-处理 请求集合
- (NSString *)keyForSessionDataTask:(NSURLSessionDataTask *)sessionDataTask {
    return [@(sessionDataTask.taskIdentifier) stringValue];
}

- (void)addRequestObject:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if (request.sessionDataTask == nil)    return;
    
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        _requestRecordDict[taskKey] = request;
    }
}

@end
