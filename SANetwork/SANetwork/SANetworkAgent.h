//
//  SANetworkAgent.h
//  ECM
//
//  Created by 学宝 on 16/1/13.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SANetworkRequest;
@protocol SANetworkRequestConfigProtocol;

@interface SANetworkAgent : NSObject

+ (SANetworkAgent *)sharedInstance;

/**
 *  @brief 添加request到请求栈中，并启动
 *
 *  @param request 一个基于SABaseRequest的实例
 */
- (void)addRequest:(__kindof SANetworkRequest *)request;

/**
 *  @brief 结束一个请求，并从请求栈中移除
 *
 *  @param request 一个基于SABaseRequest的实例
 */
- (void)removeRequest:(__kindof SANetworkRequest *)request;

@end
