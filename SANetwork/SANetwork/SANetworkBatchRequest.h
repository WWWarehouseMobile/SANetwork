//
//  SANetworkBatchRequest.h
//  ECM
//
//  Created by 学宝 on 16/1/18.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkAccessoryProtocol.h"

@class SANetworkBatchRequest;
@class SANetworkResponse;
@protocol SANetworkBatchRequestResponseDelegate <NSObject>

@optional
- (void)networkBatchRequest:(SANetworkBatchRequest *)batchRequest completedByResponseArray:(NSArray<SANetworkResponse *> *)responseArray;

@end

@class SANetworkRequest;
@protocol  SANetworkAccessoryProtocol;
@interface SANetworkBatchRequest : NSObject

@property (nonatomic, weak) id<SANetworkBatchRequestResponseDelegate>delegate;

/**
 *  @brief 当某一个请求错误时，其他请求是否继续，默认YES继续
 */
@property (nonatomic, assign) BOOL isContinueByFailResponse;

- (instancetype)initWithRequestArray:(NSArray<SANetworkRequest *> *)requestArray;

/**
 *  @brief 开始网络请求
 */
- (void)startBatchRequest;

/**
 *  @brief 停止网络请求
 */
- (void)stopBatchRequest;

/**
 *  @brief 添加实现了SANetworkAccessoryProtocol的插件对象
 *
 *  @param accessoryDelegate 插件对象
 *  @warning 务必在启动请求之前添加插件。
 */
- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate;
@end
