//
//  SANetworkAgent.m
//  ECM
//
//  Created by 学宝 on 16/1/13.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkAgent.h"
#import "SANetworkRequest.h"
#import "SANetworkResponse.h"
#import <PINCache/PINCache.h>
#import <CommonCrypto/CommonDigest.h>
#import <RealReachability/RealReachability.h>
#import "SANetworkLogger.h"

@interface SANetworkAgent ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong) NSMutableDictionary <NSString*, SANetworkRequest*>*requestRecordDict;

@property (nonatomic, assign, readonly) BOOL isReachable;

@end

@implementation SANetworkAgent

+ (SANetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestRecordDict = [NSMutableDictionary dictionary];
        [[RealReachability sharedInstance] startNotifier];
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _sessionManager.operationQueue.maxConcurrentOperationCount = 3;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    }
    return _sessionManager;
}

- (void)setupSessionManagerRequestSerializerByRequest:(SANetworkRequest<SANetworkConfigProtocol> *)request {
    //配置requestSerializerType
    switch ([self requestSerializerTypeByRequest:request]) {
        case SARequestSerializerTypeJSON:
            self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        case SARequestSerializerTypeHTTP:
            self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        default:
            break;
    }
    
    [self setupHTTPRequestHeadersByRequest:request];
    
    //配置请求超时时间
    self.sessionManager.requestSerializer.timeoutInterval = [self requestTimeoutIntervalByRequest:request];
}

- (void)setupHTTPRequestHeadersByRequest:(SANetworkRequest<SANetworkConfigProtocol> *)request {
    if ((![request.configProtocol respondsToSelector:@selector(useBaseHTTPRequestHeaders)] || [request.configProtocol useBaseHTTPRequestHeaders]) && self.baseHTTPRequestHeadersBlock) {
        NSDictionary *requestHeaders = self.baseHTTPRequestHeadersBlock();
        [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    if ([request.configProtocol respondsToSelector:@selector(customHTTPRequestHeaders)]) {
        NSDictionary *customRequestHeaders = [request.configProtocol customHTTPRequestHeaders];
        [customRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
}

#pragma mark-
#pragma mark-Getter

- (BOOL)isReachable {
    if ([[RealReachability sharedInstance] currentReachabilityStatus] == RealStatusNotReachable) {
        return NO;
    }
    return YES;
}

- (NSString *)urlStringByRequest:(SANetworkRequest*)request {
    if ([request.configProtocol respondsToSelector:@selector(customRequestURLString)]) {
        return [request.configProtocol customRequestURLString];
    }
    
    NSString *detailUrl = @"";
    if ([request.configProtocol respondsToSelector:@selector(requestMethodName)]) {
        detailUrl = [request.configProtocol requestMethodName];
    }
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    NSString *baseUrlString = nil;
    if ([request.configProtocol respondsToSelector:@selector(useViceURL)] && [request.configProtocol useViceURL]) {
        baseUrlString = self.viceBaseUrlString;
    }else{
        baseUrlString = self.mainBaseUrlString;
    }
    if (baseUrlString) {
        return [baseUrlString stringByAppendingPathComponent:detailUrl];
    }
    NSLog(@"\n\n\n请设置请求的URL\n\n\n");
    return nil;
}

- (BOOL)shouldCacheDataByRequest:(SANetworkRequest *)request {
    if ([request.configProtocol respondsToSelector:@selector(shouldCacheResponse)]) {
        return [request.configProtocol shouldCacheResponse];
    }
    return NO;
}

- (BOOL)shouldCancelPreviousRequestByRequest:(SANetworkRequest<SANetworkConfigProtocol>*)request {
    if ([request.configProtocol respondsToSelector:@selector(shouldCancelPreviousRequest)]) {
        return [request.configProtocol shouldCancelPreviousRequest];
    }
    return NO;
}

- (BOOL)isCorrectByRequestParams:(NSDictionary *)requestParams request:(SANetworkRequest *)request {
    if ([request.configProtocol respondsToSelector:@selector(isCorrectWithRequestParams:)]) {
        return [request.configProtocol isCorrectWithRequestParams:requestParams];
    }
    return YES;
}



- (NSDictionary *)requestParamByRequest:(SANetworkRequest *)request {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if (request.paramSourceDelegate) {
        NSDictionary *paramDict = [request.paramSourceDelegate requestParamDictionary];
        if (paramDict != nil) {
            [tempDict addEntriesFromDictionary:paramDict];
        }
    }
    if ([request.configProtocol respondsToSelector:@selector(useBaseRequestArgument)] && [request.configProtocol useBaseRequestArgument] && self.baseArgumentBlock) {
        NSDictionary *baseRequestArgument = self.baseArgumentBlock();
        if (baseRequestArgument != nil) {
            [tempDict addEntriesFromDictionary:baseRequestArgument];
        }
    }
    if (tempDict.count == 0) {
        return nil;
    }
    return [NSDictionary dictionaryWithDictionary:tempDict];
}

- (SARequestSerializerType)requestSerializerTypeByRequest:(SANetworkRequest<SANetworkConfigProtocol>*)request {
    if ([request.configProtocol respondsToSelector:@selector(requestSerializerType)]) {
        return [request.configProtocol requestSerializerType];
    }
    return SARequestSerializerTypeJSON;
}

- (NSTimeInterval)requestTimeoutIntervalByRequest:(SANetworkRequest<SANetworkConfigProtocol>*)request {
    if ([request.configProtocol respondsToSelector:@selector(requestTimeoutInterval)]) {
        return [request.configProtocol requestTimeoutInterval];
    }
    return 20.0f;
}

- (SARequestMethod)requestMethodByRequest:(SANetworkRequest<SANetworkConfigProtocol>*)request {
    if ([request.configProtocol respondsToSelector:@selector(requestMethod)]) {
        return [request.configProtocol requestMethod];
    }
    return SARequestMethodPost;
}

- (AFConstructingBlock)constructingBlockByRequest:(SANetworkRequest<SANetworkConfigProtocol>*)request {
    if ([request.configProtocol respondsToSelector:@selector(constructingBodyBlock)]) {
        return [request.configProtocol constructingBodyBlock];
    }
    return nil;
}

- (NSString *)keyWithURLString:(NSString *)urlString requestParam:(NSDictionary *)requestParam {
    NSString *cacheKey = [self urlStringWithOriginUrlString:urlString appendParameters:requestParam];
    return [self stringByMd5String:cacheKey];
}


#pragma mark-
#pragma mark-处理Request

- (void)addRequest:(__kindof SANetworkRequest<SANetworkConfigProtocol> *)request{
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
        [request accessoryDidStop];
        return;
    }
    
    //检查是否存在相同请求方法未完成，并根据协议接口决定是否结束之前的请求
    __block BOOL isContinuePerform = YES;
    [self.requestRecordDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SANetworkRequest * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([[self urlStringByRequest:obj] isEqualToString:requestURLString]) {
            if ([self shouldCancelPreviousRequestByRequest:request]) {
                [obj accessoryWillStart];
                [self removeRequest:obj];
                [obj accessoryDidStop];
            }else{
                isContinuePerform = NO;
            }
            *stop = YES;
        }
    }];
    if (isContinuePerform == NO){
        NSLog(@"有个请求未完成，这个请求被取消了（可设置shouldCancelPreviousRequest）");
        [request accessoryDidStop];
        return;
    }
    if (self.enableDebug) {
        [SANetworkLogger logDebugRequestInfoWithURL:requestURLString httpMethod:[self requestMethodByRequest:request] methodName:[request.configProtocol requestMethodName] params:requestParam reachabilityStatus:[[RealReachability sharedInstance] currentReachabilityStatus]];
    }
    //检测请求是否缓存数据，并执行缓存数据回调方法
    if ([self shouldCacheDataByRequest:request]) {
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            [[PINDiskCache sharedCache] objectForKey:[self keyWithURLString:requestURLString requestParam:requestParam] block:^(PINDiskCache * _Nonnull cache, NSString * _Nonnull key, id<NSCoding>  _Nullable object, NSURL * _Nullable fileURL) {
                if (object) {
                    SANetworkResponse *cacheResponse = [self networkResponseByRequest:request responseData:object networkResponseStatus:SANetworkResponseCacheStatus];
                    [request.responseDelegate networkRequest:request succeedByResponse:cacheResponse];
                }
                if (self.enableDebug) {
                    [SANetworkLogger logCacheInfoWithResponseData:object];
                }
            }];
        }
    }
    
    if (self.isReachable == NO) {
        [request accessoryDidStop];
        return;
    }

    [self setupSessionManagerRequestSerializerByRequest:request];
    __block SANetworkRequest *blockRequest = request;
    switch ([self requestMethodByRequest:request]) {
        case SARequestMethodGet:{
        request.sessionDataTask = [self.sessionManager GET:requestURLString
                                                parameters:requestParam
                                                  progress:^(NSProgress * _Nonnull downloadProgress) {
                                                      [self handleRequestProgress:downloadProgress request:blockRequest];
                                                  }
                                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                       [self handleRequestSuccess:task responseObject:responseObject];
                                                   }
                                                   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                       [self handleRequestFailure:task error:error];
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
                                                               [self handleRequestProgress:uploadProgress request:blockRequest];
                                                           }
                                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [self handleRequestSuccess:task responseObject:responseObject];
                                                            }
                                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [self handleRequestFailure:task error:error];
                                                            }];
            }else{
            request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                     parameters:requestParam
                                                       progress:^(NSProgress * _Nonnull uploadProgress) {
                                                           [self handleRequestProgress:uploadProgress request:blockRequest];
                                                       }
                                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                            [self handleRequestSuccess:task responseObject:responseObject];
                                                        }
                                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                            [self handleRequestFailure:task error:error];
                                                        }];
            }
        }
            break;
        default:
            break;
    }
    [self addRequestObject:request];
}

- (void)removeRequest:(__kindof SANetworkRequest *)request {
    [request.sessionDataTask cancel];
    [self removeRequestObject:request];
}

#pragma mark-
#pragma mark-处理请求响应结果

- (void)beforePerformSuccessWithResponse:(SANetworkResponse *)response request:(SANetworkRequest *)request{
    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:beforePerformSuccessWithResponse:)]) {
        [request.interceptorDelegate networkRequest:request beforePerformSuccessWithResponse:response];
    }
}
- (void)afterPerformSuccessWithResponse:(SANetworkResponse *)response request:(SANetworkRequest *)request{
    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:afterPerformSuccessWithResponse:)]) {
        [request.interceptorDelegate networkRequest:request afterPerformSuccessWithResponse:response];
    }
}

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


- (SANetworkResponse *)networkResponseByRequest:(SANetworkRequest *)request responseData:(id)responseData networkResponseStatus:(SANetworkResponseStatus)networkResponseStatus {
    Class responseClass = Nil;
    if ([request.configProtocol respondsToSelector:@selector(responseDataModelClass)]) {
        responseClass = [request.configProtocol responseDataModelClass];
    }
    SANetworkResponse *networkResponse = [[SANetworkResponse alloc] initWithResponseData:responseData responseModelClass:responseClass requestTag:request.tag networkResponseStatus:networkResponseStatus];
    return networkResponse;
}


- (void)handleRequestProgress:(NSProgress *)progress request:(SANetworkRequest *)request {
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:requestingByProgress:)]) {
        [request.responseDelegate networkRequest:request requestingByProgress:progress];
    }
}

- (void)handleRequestSuccess:(NSURLSessionDataTask *)sessionDataTask responseObject:(id)response {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    SANetworkRequest *request = _requestRecordDict[taskKey];
    if (request == nil){
        NSLog(@"请求实例被意外释放!");
        return;
    }
    [request accessoryWillStop];
    [self removeRequestObject:request];
    
    BOOL isAuthentication = YES;
    if (self.baseAuthenticationBlock) {
        isAuthentication = self.baseAuthenticationBlock(request,response);
    }
    if(isAuthentication && [request.configProtocol isCorrectWithResponseData:response]){
        if ([self shouldCacheDataByRequest:request]) {
            [[PINDiskCache sharedCache] setObject:response forKey:[self keyWithURLString:[self urlStringByRequest:request] requestParam:[self requestParamByRequest:request]]];
        }
        
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            SANetworkResponse *successResponse = [self networkResponseByRequest:request responseData:response networkResponseStatus:SANetworkResponseSuccessStatus];
            [self beforePerformSuccessWithResponse:successResponse request:request];
            [request.responseDelegate networkRequest:request succeedByResponse:successResponse];
            [self afterPerformSuccessWithResponse:successResponse request:request];
        }
    } else {
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            SANetworkResponse *dataErrorResponse = [self networkResponseByRequest:request responseData:response networkResponseStatus:isAuthentication ? SANetworkResponseIncorrectStatus : SANetworkResponseAuthenticationFailStatus];
            [self beforePerformFailWithResponse:dataErrorResponse request:request];
            [request.responseDelegate networkRequest:request failedByResponse:dataErrorResponse];
            [self afterPerformFailWithResponse:dataErrorResponse request:request];
        }
    }
    [request accessoryDidStop];
    if (self.enableDebug) {
        [SANetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:response authentication:isAuthentication error:nil];
    }
}

- (void)handleRequestFailure:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    SANetworkRequest *request = _requestRecordDict[taskKey];
    [request accessoryWillStop];
    [self removeRequestObject:request];
    if (request == nil) {
        [request accessoryDidStop];
        return;
    }
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
        SANetworkResponse *failureResponse = [self networkResponseByRequest:request responseData:nil networkResponseStatus:SANetworkResponseFailureStatus];
        [self beforePerformFailWithResponse:failureResponse request:request];
        [request.responseDelegate networkRequest:request failedByResponse:failureResponse];
        [self afterPerformFailWithResponse:failureResponse request:request];
    }
    [request accessoryDidStop];
    if (self.enableDebug) {
        [SANetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:nil authentication:YES error:error];
    }
}

#pragma mark-
#pragma mark-处理 请求集合
- (NSString *)keyForSessionDataTask:(NSURLSessionDataTask *)sessionDataTask {
    return [@(sessionDataTask.taskIdentifier) stringValue];
}

- (void)addRequestObject:(SANetworkRequest *)request {
    if (request.sessionDataTask == nil)    return;
    
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        _requestRecordDict[taskKey] = request;
    }
}

- (void)removeRequestObject:(SANetworkRequest *)request {
    if(request.sessionDataTask == nil)  return;
    
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        [_requestRecordDict removeObjectForKey:taskKey];
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
