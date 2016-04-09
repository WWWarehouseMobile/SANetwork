//
//  SANetworkResponseProtocol.h
//  ECM
//
//  Created by 学宝 on 16/1/15.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SANetworkRequest;
@class SANetworkResponse;
@protocol SANetworkResponseProtocol <NSObject>

@optional

/**
 *  @brief 请求成功的回调
 *
 *  @param networkRequest 请求对象
 *  @param response       响应的数据（SANetworkResponse）
 *  @warning 若此请求允许缓存，请在此回调中根据response 的isCache 或 networkStatus 属性 做判断处理
 */
- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response;

/**
 *  @brief 请求失败的回调
 *
 *  @param networkRequest 请求对象
 *  @param response       响应的数据（SANetworkResponse）
 */
- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response;

/**
 *  @brief 请求进度的回调，一般适用于上传文件
 *
 *  @param networkRequest 请求对象
 *  @param progress       进度
 */
- (void)networkRequest:(SANetworkRequest *)networkRequest requestingByProgress:(NSProgress *)progress;

@end
