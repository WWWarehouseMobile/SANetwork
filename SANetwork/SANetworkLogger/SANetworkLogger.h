//
//  SALogger.h
//  SANetwork
//
//  Created by ISCS01 on 16/4/9.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SANetworkLogger : NSObject

+ (void)logDebugRequestInfoWithURL:(NSString *)url
                        httpMethod:(NSInteger)httpMethod
                            params:(NSDictionary *)params reachabilityStatus:(NSInteger)reachabilityStatus;

+ (void)logDebugResponseInfoWithSessionDataTask:(NSURLSessionDataTask *)sessionDataTask
                                 responseObject:(id)response
                                 authentication:(BOOL)authentication
                                          error:(NSError *)error;

+ (void)logCacheInfoWithResponseData:(id)responseData;
@end
