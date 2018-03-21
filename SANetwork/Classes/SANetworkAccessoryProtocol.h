//
//  SANetworkAccessoryProtocol.h
//  ECM
//
//  Created by 学宝 on 16/1/15.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkConstant.h"

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
 请求全过程

 @param networkStatus 请求状态
 */
- (void)networkRequestAccessoryByStatus:(SANetworkStatus)networkStatus;
@end
