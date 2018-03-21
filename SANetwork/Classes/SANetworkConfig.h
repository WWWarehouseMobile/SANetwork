//
//  SANetworkConfig.h
//  SANetworkDemo
//
//  Created by 学宝 on 16/7/21.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkServiceProtocol.h"

/**
 *  @brief 网络接口配置类
 */
@interface SANetworkConfig : NSObject


/**
 生成网络接口配置单例方法

 @return 网络接口配置单例
 */
+ (SANetworkConfig *)sharedInstance;

/**
 *  @brief 是否打开debug日志，默认关闭
 */
@property (nonatomic, assign) BOOL enableDebug;


/**
 获取网络接口不同服务配置对象

 @param serviceIdentifier 服务配置对象的存储标示
 @return 服务配置对象
 */
- (NSObject<SANetworkServiceProtocol> *)serviceObjectWithServiceIdentifier:(NSString *)serviceIdentifier;


/**
 设置网络接口所需的服务配置对象

 @param serviceObject 服务配置对象
 @param serviceIdentifier 服务配置对象的存储标示
 */
- (void)registerServiceObject:(NSObject<SANetworkServiceProtocol> *)serviceObject serviceIdentifier:(NSString *)serviceIdentifier;

@end
