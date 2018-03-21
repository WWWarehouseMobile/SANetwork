//
//  SANetworkChainRequest.h
//  ECM
//
//  Created by 学宝 on 16/1/18.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SANetworkChainRequest;
@class SANetworkRequest;
@class SANetworkResponse;

/**
 链式请求回调代理
 */
@protocol SANetworkChainRequestResponseDelegate <NSObject>

@optional


/**
 获取链式请求中需要启动的下一个接口对象。链式请求中，一个请求完成时触发
 
  @warning 链式请求中，若是有请求失败，将停止。此回调方法，链式对象只会在接口请求成功后去调用

 @param chainRequest 链式请求对象
 @param request 最后完成的请求对象 (刚刚完成的请求对象)
 @param response 最后完成请求的响应数据
 @return 下一个要启动的接口对象
 */
- (__kindof SANetworkRequest *)networkChainRequest:(SANetworkChainRequest *)chainRequest nextNetworkRequestByNetworkRequest:(__kindof SANetworkRequest *)request finishedByResponse:(SANetworkResponse *)response;


/**
 链式请求失败时的回调

 @param chainRequest 链式请求对象
 @param request 接口调用失败的请求对象
 @param response 接口调用失败的响应对象
 */
- (void)networkChainRequest:(SANetworkChainRequest *)chainRequest networkRequest:(__kindof SANetworkRequest *)request failedByResponse:(SANetworkResponse *)response;

@end

@protocol  SANetworkAccessoryProtocol;


/**
 链式请求对象
 */
@interface SANetworkChainRequest : NSObject

/**
 链式请求的代理对象
 */
@property (nonatomic, weak) id<SANetworkChainRequestResponseDelegate> delegate;

/**
  初始化链式请求，需要配置一个根请求
 *
 @param networkRequest 第一个请求
 *
 @return 链式请求对象
 */
- (instancetype)initWithRootNetworkRequest:(__kindof SANetworkRequest *)networkRequest;


/**
 *  @brief 启动链式请求
 */
- (void)startChainRequest;

/**
 *  @brief 取消链式请求
 */
- (void)stopChainRequest;

/**
 添加实现了SANetworkAccessoryProtocol的插件对象
 @warning 务必在启动请求之前添加插件。
 
 @param accessoryDelegate  accessoryDelegate 插件对象。链式请求于请求插件完成协议状态 = 最后一个请求的状态
 */
- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate;

@end
