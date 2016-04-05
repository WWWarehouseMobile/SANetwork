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
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.operationQueue.maxConcurrentOperationCount = 3;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        _requestRecordDict = [NSMutableDictionary dictionary];
        [[RealReachability sharedInstance] startNotifier];
    }
    return self;
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
    if ([request.configProtocol respondsToSelector:@selector(apiMethodName)]) {
        detailUrl = [request.configProtocol apiMethodName];
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

- (NSDictionary *)requestParamByRequest:(SANetworkRequest<SANetworkConfigProtocol>*)request {
    BOOL useBaseRequestArgument = YES;
    if ([request.configProtocol respondsToSelector:@selector(useBaseRequestArgument)]) {
        useBaseRequestArgument = [request.configProtocol useBaseRequestArgument];
    }
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:request.requestArgument];
    if (useBaseRequestArgument && self.baseArgumentBlock) {
        NSDictionary *baseRequestArgument = self.baseArgumentBlock();
        if (baseRequestArgument != nil) {
            [tempDict addEntriesFromDictionary:baseRequestArgument];
        }
    }
    return [NSDictionary dictionaryWithDictionary:tempDict];
}

- (SARequestSerializerType)requestSerializerTypeByRequest:(SANetworkRequest<SANetworkConfigProtocol>*)request {
    SARequestSerializerType requestSerializerType = SARequestSerializerTypeHTTP;
    if ([request.configProtocol respondsToSelector:@selector(requestSerializerType)]) {
        requestSerializerType = [request.configProtocol requestSerializerType];
    }
    return requestSerializerType;
}

- (NSTimeInterval)requestTimeoutIntervalByRequest:(SANetworkRequest<SANetworkConfigProtocol>*)request {
    NSTimeInterval timeoutInterval = 30.0f;
    if ([request.configProtocol respondsToSelector:@selector(requestTimeoutInterval)]) {
        timeoutInterval = [request.configProtocol requestTimeoutInterval];
    }
    return timeoutInterval;
}

- (SARequestMethod)requestMethodByRequest:(SANetworkRequest<SANetworkConfigProtocol>*)request {
    SARequestMethod requestMethod = SARequestMethodPost;
    if ([request.configProtocol respondsToSelector:@selector(requestMethod)]) {
        requestMethod = [request.configProtocol requestMethod];
    }
    return requestMethod;
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
    if ([request.configProtocol respondsToSelector:@selector(shouldPerformRequestWithParams:)]) {
        NSAssert([request.configProtocol shouldPerformRequestWithParams:requestParam], @"参数配置有误！请查看shouldPerformRequestWithParams: !");
    }

    //检查是否存在相同请求方法未完成，并根据协议接口决定是否结束之前的请求
    __block BOOL isContinuePerform = YES;
    [self.requestRecordDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SANetworkRequest * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([[self urlStringByRequest:obj] isEqualToString:requestURLString] && [requestParam isEqualToDictionary:obj.requestArgument]) {
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
        [request accessoryDidStop];
        return;
    }
    
    //检测请求是否缓存数据，并执行缓存数据回调方法
    if ([self shouldCacheDataByRequest:request]) {
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            [[PINDiskCache sharedCache] objectForKey:[self keyWithURLString:requestURLString requestParam:requestParam] block:^(PINDiskCache * _Nonnull cache, NSString * _Nonnull key, id<NSCoding>  _Nullable object, NSURL * _Nullable fileURL) {
                if (object) {
                    SANetworkResponse *cacheResponse = [[SANetworkResponse alloc] initWithResponse:object sessionDataTask:nil requestTag:request.tag networkStatus:SANetworkStatusCache];
                    [request.responseDelegate networkRequest:request succeedByResponse:cacheResponse];
                }
            }];
        }
    }
    
    if (self.isReachable == NO) {
        [request accessoryDidStop];
        return;
    }
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
    
    //配置请求超时时间
    self.sessionManager.requestSerializer.timeoutInterval = [self requestTimeoutIntervalByRequest:request];

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
                __weak typeof(self)weakSelf = self;
            request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                     parameters:requestParam
                                                       progress:^(NSProgress * _Nonnull uploadProgress) {
                                                           [self handleRequestProgress:uploadProgress request:blockRequest];
                                                       }
                                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                            __strong typeof(weakSelf)strongSelf = weakSelf;
                                                            [strongSelf handleRequestSuccess:task responseObject:responseObject];
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

- (void)handleRequestProgress:(NSProgress *)progress request:(SANetworkRequest *)request {
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:requestingByProgress:)]) {
        [request.responseDelegate networkRequest:request requestingByProgress:progress];
    }
}

- (void)handleRequestSuccess:(NSURLSessionDataTask *)sessionDataTask responseObject:(id)response {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    SANetworkRequest *request = _requestRecordDict[taskKey];
    [request accessoryWillStop];
    [self removeRequestObject:request];
    if (request == nil){
        [request accessoryDidStop];
        return;
    }
    
    BOOL isAuthentication = YES;
    if (self.baseAuthenticationBlock) {
        isAuthentication = self.baseAuthenticationBlock(request,response);
    }
    if(isAuthentication && [request.responseDelegate networkRequest:request isCorrectWithResponse:response]){
        if ([self shouldCacheDataByRequest:request]) {
            [[PINDiskCache sharedCache] setObject:response forKey:[self keyWithURLString:[self urlStringByRequest:request] requestParam:request.requestArgument]];
        }
        
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            SANetworkResponse *successResponse = [[SANetworkResponse alloc] initWithResponse:response sessionDataTask:sessionDataTask requestTag:request.tag networkStatus:SANetworkStatusSuccess];
            [request.responseDelegate networkRequest:request succeedByResponse:successResponse];
        }
    } else {
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            SANetworkResponse *dataErrorResponse = [[SANetworkResponse alloc] initWithResponse:response sessionDataTask:sessionDataTask requestTag:request.tag networkStatus:isAuthentication ? SANetworkStatusResponseDataIncorrect : SANetworkStatusResponseDataFailAuthentication];
            [request.responseDelegate networkRequest:request failedByResponse:dataErrorResponse];
        }
    }
    [request accessoryDidStop];
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
        SANetworkResponse *timeoutResponse = [[SANetworkResponse alloc] initWithResponse:nil sessionDataTask:sessionDataTask requestTag:request.tag networkStatus:SANetworkStatusTimeout];
        [request.responseDelegate networkRequest:request failedByResponse:timeoutResponse];
    }
    [request accessoryDidStop];
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
