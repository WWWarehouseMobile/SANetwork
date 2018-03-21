//
//  SANetworkInterceptorProtocol.h
//  ECM
//
//  Created by 学宝 on 16/1/15.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SANetworkRequest;
@class SANetworkResponse;

/**
 网络接口拦截器协议
 */
@protocol SANetworkInterceptorProtocol <NSObject>

@optional


/**
 在请求成功回调之前执行

 @param networkRequest 网络接口请求对象
 @param networkResponse 网络接口响应对象
 */
- (void)networkRequest:(SANetworkRequest *)networkRequest beforePerformSuccessWithResponse:(SANetworkResponse *)networkResponse;


/**
 在请求成功回调之后执行

 @param networkRequest 网络接口请求对象
 @param networkResponse 网络接口响应对象
 */
- (void)networkRequest:(SANetworkRequest *)networkRequest afterPerformSuccessWithResponse:(SANetworkResponse *)networkResponse;


/**
 在请求失败回调之前执行
 
 @param networkRequest 网络接口请求对象
 @param networkResponse 网络接口响应对象
 */
- (void)networkRequest:(SANetworkRequest *)networkRequest beforePerformFailWithResponse:(SANetworkResponse *)networkResponse;

/**
 在请求失败回调之后执行
 
 @param networkRequest 网络接口请求对象
 @param networkResponse 网络接口响应对象
 */
- (void)networkRequest:(SANetworkRequest *)networkRequest afterPerformFailWithResponse:(SANetworkResponse *)networkResponse;

@end
