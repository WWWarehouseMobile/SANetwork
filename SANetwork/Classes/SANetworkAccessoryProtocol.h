//
//  SANetworkAccessoryProtocol.h
//  ECM
//
//  Created by 学宝 on 16/1/15.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkConstant.h"
#import "SANetworkResponse.h"

/**
 *  @brief 请求插件协议
 */
@protocol SANetworkAccessoryProtocol <NSObject>

@optional

/**
 *  @brief 请求将要执行
 */
- (void)networkRequestAccessoryWillStart;

/**
 *  @brief 请求已经执行
 */
- (void)networkRequestAccessoryDidStart;


/**
 请求完成执行
 @warning 与 networkRequestAccessoryDidEndByResponse: 会同时被调用
 
 @param networkStatus 请求状态
 */
- (void)networkRequestAccessoryByStatus:(SANetworkStatus)networkStatus;

/**
 请求完成执行
 @warning 与 networkRequestAccessoryByStatus: 会同时被调用
 
 @param response 响应数据
 */
- (void)networkRequestAccessoryDidEndByResponse:(SANetworkResponse *)response;

@end
