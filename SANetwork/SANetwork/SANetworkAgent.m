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
#import <PINCache/PINCache.h>

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
        _sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _sessionManager.responseSerializer.acceptableContentTypes = [SANetworkConfig sharedInstance].acceptableContentTypes;
    }
    return _sessionManager;
}

#pragma mark-
#pragma mark-Getter

- (NSString *)urlStringByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    NSString *detailUrl = @"";
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethodName)]) {
        detailUrl = [request.requestConfigProtocol requestMethodName];
    }
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    
    NSString *serviceURLString = nil;
    if ([SANetworkConfig sharedInstance].urlSeriveDictionary && [request.requestConfigProtocol respondsToSelector:@selector(serviceKey)]) {
        NSString *serviceKey = [request.requestConfigProtocol serviceKey];
        serviceURLString = [SANetworkConfig sharedInstance].urlSeriveDictionary[serviceKey];
        if ([serviceURLString hasPrefix:@"http"]) {
            return [serviceURLString stringByAppendingPathComponent:detailUrl];
        }
    }
    
    NSString *baseUrlString = nil;
    if ([request.requestConfigProtocol respondsToSelector:@selector(useViceURL)] && [request.requestConfigProtocol useViceURL]) {
        baseUrlString = [SANetworkConfig sharedInstance].viceBaseUrlString;
    }else{
        baseUrlString = [SANetworkConfig sharedInstance].mainBaseUrlString;
    }
    
    if (baseUrlString == nil || ![baseUrlString hasPrefix:@"http"]){
        NSLog(@"\n\n\n请设置正确的URL\n\n\n");
        return nil;
    }else if (serviceURLString.length) {
        baseUrlString = [baseUrlString stringByAppendingString:serviceURLString];
    }
    return [baseUrlString stringByAppendingPathComponent:detailUrl];
}

- (NSDictionary *)requestParamByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if (request.requestParamSourceDelegate) {
        NSDictionary *paramDict = [request.requestParamSourceDelegate requestParamDictionary];
        if (paramDict != nil) {
            [tempDict addEntriesFromDictionary:paramDict];
        }
    }
    
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseRequestParamSource)] || [request.requestConfigProtocol useBaseRequestParamSource]) && [SANetworkConfig sharedInstance].baseParamSourceBlock) {
        NSDictionary *baseRequestParamSource = [SANetworkConfig sharedInstance].baseParamSourceBlock();
        if (baseRequestParamSource != nil) {
            [tempDict addEntriesFromDictionary:baseRequestParamSource];
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

- (BOOL)shouldCancelPreviousRequestByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(shouldCancelPreviousRequest)]) {
        return [request.requestConfigProtocol shouldCancelPreviousRequest];
    }
    return NO;
}

- (SARequestMethod)requestMethodByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethod)]) {
        return [request.requestConfigProtocol requestMethod];
    }
    return SARequestMethodPost;
}

- (BOOL)shouldCacheDataByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(shouldCacheResponse)]) {
        return [request.requestConfigProtocol shouldCacheResponse];
    }
    return NO;
}

- (NSString *)keyWithURLString:(NSString *)urlString requestParam:(NSDictionary *)requestParam {
    NSString *cacheKey = [self urlStringWithOriginUrlString:urlString appendParameters:requestParam];
    return [self stringByMd5String:cacheKey];
}

- (void)setupSessionManagerRequestSerializerByRequest:(__kindof SANetworkRequest<SANetworkRequestConfigProtocol> *)request {
    //配置requestSerializerType
    SARequestSerializerType requestSerializerType;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestSerializerType)]) {
        requestSerializerType = [request.requestConfigProtocol requestSerializerType];
    }else{
        requestSerializerType = [SANetworkConfig sharedInstance].requestSerializerType;
    }
    if (requestSerializerType == SARequestSerializerTypeHTTP && [self.sessionManager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]) {
        self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }else if (requestSerializerType == SARequestSerializerTypeJSON && ![self.sessionManager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]){
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }

    //配置responseSerializerType
    SAResponseSerializerType responseSerializerType;
    if ([request.requestConfigProtocol respondsToSelector:@selector(responseSerializerType)]) {
        responseSerializerType = [request.requestConfigProtocol responseSerializerType];
    }else{
        responseSerializerType = [SANetworkConfig sharedInstance].responseSerializerType;
    }
    if (responseSerializerType == SAResponseSerializerTypeHTTP && [self.sessionManager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
        self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [SANetworkConfig sharedInstance].acceptableContentTypes;
    }else if (responseSerializerType == SAResponseSerializerTypeJSON && ![self.sessionManager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]){
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [SANetworkConfig sharedInstance].acceptableContentTypes;
    }
    
    //配置请求头
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseHTTPRequestHeaders)] || [request.requestConfigProtocol useBaseHTTPRequestHeaders]) && [SANetworkConfig sharedInstance].baseHTTPRequestHeadersBlock) {
        NSDictionary *requestHeaders = [SANetworkConfig sharedInstance].baseHTTPRequestHeadersBlock();
        [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    if ([request.requestConfigProtocol respondsToSelector:@selector(customHTTPRequestHeaders)]) {
        NSDictionary *customRequestHeaders = [request.requestConfigProtocol customHTTPRequestHeaders];
        [customRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    //配置请求超时时间
    NSTimeInterval timeoutInterval = [SANetworkConfig sharedInstance].requestTimeoutInterval;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestTimeoutInterval)]) {
        timeoutInterval = [request.requestConfigProtocol requestTimeoutInterval];
    }
    self.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
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
    if ([requestURLString hasPrefix:@"https"]) {
        AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
        [securityPolicy setAllowInvalidCertificates:YES];
        self.sessionManager.securityPolicy = securityPolicy;
    }
    
    NSDictionary *requestParam = [self requestParamByRequest:request];
    //检查参数配置
    if (![self isCorrectByRequestParams:requestParam request:request]) {
        NSLog(@"参数配置有误！请查看isCorrectWithRequestParams: !");
        SANetworkResponse *paramIncorrectResponse = [[SANetworkResponse alloc] initWithResponseData:nil requestTag:request.tag networkStatus:SANetworkRequestParamIncorrectStatus];
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            [request.responseDelegate networkRequest:request failedByResponse:paramIncorrectResponse];
        }
        [request stopRequest];
        return;
    }
    
    //检查是否存在相同请求方法未完成，并根据协议接口决定是否结束之前的请求
    BOOL isContinuePerform = YES;
    for (SANetworkRequest<SANetworkRequestConfigProtocol> *requestingObj in self.requestRecordDict.allValues) {
        if ([[self urlStringByRequest:requestingObj] isEqualToString:requestURLString]) {
            if ([self shouldCancelPreviousRequestByRequest:request]) {
                [requestingObj stopRequest];
            }else{
                isContinuePerform = NO;
            }
            break;
        }
    }
    
    if (isContinuePerform == NO){
        NSLog(@"有个请求未完成，这个请求被取消了（可设置shouldCancelPreviousRequest）");
        [request stopRequest];
        return;
    }
    
    if ([SANetworkConfig sharedInstance].enableDebug) {
        [SANetworkLogger logDebugRequestInfoWithURL:requestURLString httpMethod:[self requestMethodByRequest:request] params:requestParam reachabilityStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]];
    }
    
    //检测请求是否缓存数据，并执行缓存数据回调方法
    if ([self shouldCacheDataByRequest:request]) {
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            [[PINDiskCache sharedCache] objectForKey:[self keyWithURLString:requestURLString requestParam:requestParam] block:^(PINDiskCache * _Nonnull cache, NSString * _Nonnull key, id<NSCoding>  _Nullable object, NSURL * _Nullable fileURL) {
                if (object) {
                    SANetworkResponse *cacheResponse = [[SANetworkResponse alloc] initWithResponseData:object requestTag:request.tag networkStatus:SANetworkResponseDataCacheStatus];
                    [request.responseDelegate networkRequest:request succeedByResponse:cacheResponse];
                }
                if ([SANetworkConfig sharedInstance].enableDebug) {
                    [SANetworkLogger logCacheInfoWithResponseData:object];
                }
            }];
        }
    }
    
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            SANetworkResponse *notReachableResponse = [[SANetworkResponse alloc] initWithResponseData:nil requestTag:request.tag networkStatus:SANetworkNotReachableStatus];
            [request.responseDelegate networkRequest:request failedByResponse:notReachableResponse];
        }
        [request stopRequest];
        return;
    }
    
    [self setupSessionManagerRequestSerializerByRequest:request];
    __block SANetworkRequest<SANetworkRequestConfigProtocol> *blockRequest = request;
    __weak typeof(self)weakSelf = self;
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
        [request stopRequest];
        return;
    }
    BOOL isAuthentication = YES;
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseAuthentication)] || [request.requestConfigProtocol useBaseAuthentication]) && [SANetworkConfig sharedInstance].baseAuthenticationBlock) {
        isAuthentication = [SANetworkConfig sharedInstance].baseAuthenticationBlock(request,response);
    }
    if(isAuthentication && [request.requestConfigProtocol isCorrectWithResponseData:response]){
        if ([self shouldCacheDataByRequest:request]) {
            [[PINDiskCache sharedCache] setObject:response forKey:[self keyWithURLString:[self urlStringByRequest:request] requestParam:[self requestParamByRequest:request]]];
        }
        
        SANetworkResponse *successResponse = [[SANetworkResponse alloc] initWithResponseData:response requestTag:request.tag networkStatus:SANetworkResponseDataSuccessStatus];
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
        SANetworkResponse *dataErrorResponse = [[SANetworkResponse alloc] initWithResponseData:response requestTag:request.tag networkStatus:isAuthentication ? SANetworkResponseDataIncorrectStatus : SANetworkResponseDataAuthenticationFailStatus];
        [self beforePerformFailWithResponse:dataErrorResponse request:request];
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            [request.responseDelegate networkRequest:request failedByResponse:dataErrorResponse];
        }
        [self afterPerformFailWithResponse:dataErrorResponse request:request];
    }
    [request stopRequest];
    
    if ([SANetworkConfig sharedInstance].enableDebug) {
        [SANetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:response authentication:isAuthentication error:nil];
    }
}

- (void)handleRequestFailure:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    SANetworkRequest<SANetworkRequestConfigProtocol> *request = _requestRecordDict[taskKey];
    if (request == nil) {
        NSLog(@"请求实例被意外释放!");
        [request stopRequest];
        return;
    }
    SANetworkResponse *failureResponse = [[SANetworkResponse alloc] initWithResponseData:nil requestTag:request.tag networkStatus:SANetworkResponseFailureStatus];
    [self beforePerformFailWithResponse:failureResponse request:request];
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
        [request.responseDelegate networkRequest:request failedByResponse:failureResponse];
    }
    [self afterPerformFailWithResponse:failureResponse request:request];
    [request stopRequest];
    if ([SANetworkConfig sharedInstance].enableDebug) {
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


#pragma mark-
#pragma mark-Other

- (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters {
    NSString *filteredUrl = originUrlString;
    NSMutableString *urlParametersString = [[NSMutableString alloc] initWithString:@""];
    if (parameters && parameters.count > 0) {
        for (NSString *key in parameters) {
            NSString *value = parameters[key];
            value = [NSString stringWithFormat:@"%@",value];
            value = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)value, CFSTR("."), CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);;
            [urlParametersString appendFormat:@"&%@=%@", key, value];
        }
    }
    if (urlParametersString.length > 0) {
        if ([originUrlString rangeOfString:@"?"].location != NSNotFound) {
            filteredUrl = [filteredUrl stringByAppendingString:urlParametersString];
        } else {
            filteredUrl = [filteredUrl stringByAppendingFormat:@"?%@", [urlParametersString substringFromIndex:1]];
        }
        return filteredUrl;
    } else {
        return originUrlString;
    }
}

- (NSString *)stringByMd5String:(NSString *)string {
    if(string == nil || [string length] == 0)
        return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}
@end
