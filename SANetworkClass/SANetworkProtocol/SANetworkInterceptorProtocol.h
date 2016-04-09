//
//  SANetworkInterceptorProtocol.h
//  ECM
//
//  Created by 学宝 on 16/1/15.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SANetworkRequest;
@class SANetworkResponse;
@protocol SANetworkInterceptorProtocol <NSObject>

@optional

- (void)networkRequest:(SANetworkRequest *)networkRequest beforePerformSuccessWithResponse:(SANetworkResponse *)networkResponse;

- (void)networkRequest:(SANetworkRequest *)networkRequest afterPerformSuccessWithResponse:(SANetworkResponse *)networkResponse;

- (void)networkRequest:(SANetworkRequest *)networkRequest beforePerformFailWithResponse:(SANetworkResponse *)networkResponse;

- (void)networkRequest:(SANetworkRequest *)networkRequest afterPerformFailWithResponse:(SANetworkResponse *)networkResponse;

@end
