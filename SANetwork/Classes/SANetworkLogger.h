//
//  SALogger.h
//  SANetwork
//
//  Created by 学宝 on 16/4/9.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 日志打印输出类
 */
@interface SANetworkLogger : NSObject


/**
 接口请求信息日志输出方法

 @param url 请求的url
 @param httpMethod 请求方式
 @param params 请求参数
 @param reachabilityStatus 网络状态
 */
+ (void)logDebugRequestInfoWithURL:(NSString *)url
                        httpMethod:(NSInteger)httpMethod
                            params:(NSDictionary *)params reachabilityStatus:(NSInteger)reachabilityStatus;


/**
 接口响应信息日志输出方法

 @param sessionDataTask 执行请求的sessionDataTask
 @param response 响应数据
 @param authentication 是否通过验证
 @param error error对象
 */
+ (void)logDebugResponseInfoWithSessionDataTask:(NSURLSessionDataTask *)sessionDataTask
                                 responseObject:(id)response
                                 authentication:(BOOL)authentication
                                          error:(NSError *)error;
@end
