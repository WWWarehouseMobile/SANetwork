//
//  SANetworkRequest.h
//  ECM
//
//  Created by 学宝 on 16/1/16.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "SANetworkConfigProtocol.h"
#import "SANetworkAccessoryProtocol.h"
#import "SANetworkResponseProtocol.h"


@interface SANetworkRequest : NSObject

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, strong) NSDictionary<NSString*,id> *requestArgument;

@property (nonatomic, weak) id <SANetworkAccessoryProtocol>accessoryDelegate;

@property (nonatomic, weak) id <SANetworkResponseProtocol>responseDelegate;

@property (nonatomic, weak, readonly) id <SANetworkConfigProtocol> configProtocol;

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

@interface SANetworkRequest (Accessory)
- (void)accessoryWillStart;
- (void)accessoryWillStop;
- (void)accessoryDidStop;
@end