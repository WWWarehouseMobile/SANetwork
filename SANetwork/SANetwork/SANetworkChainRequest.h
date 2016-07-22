//
//  SANetworkChainRequest.h
//  ECM
//
//  Created by 学宝 on 16/1/18.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SANetworkChainRequest;
@class SANetworkRequest;
@class SANetworkResponse;
@protocol SANetworkChainRequestResponseDelegate <NSObject>

@optional

- (__kindof SANetworkRequest *)networkChainRequest:(SANetworkChainRequest *)chainRequest nextNetworkRequestByNetworkRequest:(__kindof SANetworkRequest *)request finishedByResponse:(SANetworkResponse *)response;

- (void)networkChainRequest:(SANetworkChainRequest *)chainRequest networkRequest:(__kindof SANetworkRequest *)request failedByResponse:(SANetworkResponse *)response;

@end

@protocol  SANetworkAccessoryProtocol;

@interface SANetworkChainRequest : NSObject

@property (nonatomic, weak) id<SANetworkChainRequestResponseDelegate> delegate;

/**
 *  @brief 初始化链式请求，需要配置一个根请求
 *
 *  @param networkRequest 第一个请求
 *
 *  @return 链式请求对象
 */
- (instancetype)initWithRootNetworkRequest:(__kindof SANetworkRequest *)networkRequest;


/**
 *  @brief 启动链式请求
 */
- (void)startChainRequest;

/**
 *  @brief 停止链式请求，若启用插件，
 */
- (void)stopChainRequest;

/**
 *  @brief 添加实现了SANetworkAccessoryProtocol的插件对象
 *
 *  @param accessoryDelegate 插件对象
 
 *  @warning 务必在启动请求之前添加插件。
 */
- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate;

@end
