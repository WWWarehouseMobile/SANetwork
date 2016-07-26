//
//  SANetworkRequest.h
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/22.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkAccessoryProtocol.h"
#import "SANetworkInterceptorProtocol.h"
#import "SANetworkRequestConfigProtocol.h"
#import "SANetworkRequestParamSourceProtocol.h"
#import "SANetworkResponseProtocol.h"

@interface SANetworkRequest : NSObject

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, weak, readonly) NSObject<SANetworkRequestConfigProtocol> *requestConfigProtocol;
@property (nonatomic, weak) id <SANetworkRequestParamSourceProtocol>requestParamSourceDelegate;

@property (nonatomic, weak) id <SANetworkResponseProtocol>responseDelegate;
@property (nonatomic, weak) id <SANetworkInterceptorProtocol>interceptorDelegate;

@property (nonatomic, weak) id <SANetworkAccessoryProtocol>accessoryDelegate;

/**
 *  @brief 开始网络请求，使用delegate 方式使用这个方法
 */
- (void)startRequest;

/**
 *  @brief 停止网络请求
 */
- (void)stopRequest;

/**
 *  @brief 添加实现了SANetworkAccessoryProtocol的插件对象
 *
 *  @param accessoryDelegate 插件对象
 *  @warning 务必在启动请求之前添加插件。
 */
- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate;


@end
