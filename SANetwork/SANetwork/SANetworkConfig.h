//
//  SANetworkConfig.h
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/21.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkServiceProtocol.h"

@protocol SANetworkConfigDataSource;
/**
 *  @brief 网络配置类
 */
@interface SANetworkConfig : NSObject

+ (SANetworkConfig *)sharedInstance;

@property (nonatomic, weak) id<SANetworkConfigDataSource> dataSource;

/**
 *  @brief 是否打开debug日志，默认关闭
 */
@property (nonatomic, assign) BOOL enableDebug;

- (NSObject<SANetworkServiceProtocol> *)serviceObjectWithServiceIdentifier:(NSString *)serviceIdentifier;

@end

@protocol SANetworkConfigDataSource <NSObject>

@required
/*
 * key为service的Identifier
 * value为service对象，此对象必须要实现SANetworkServiceProtocol协议
 */
- (NSDictionary<NSString *, NSObject<SANetworkServiceProtocol> *> *)servicesKindsOfNetwork;

@end
