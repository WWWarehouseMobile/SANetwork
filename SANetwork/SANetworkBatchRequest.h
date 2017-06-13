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

/**
 批量请求代理
 */
@protocol SANetworkBatchRequestResponseDelegate <NSObject>

@optional

/**
 批量请求结束回调方法

 @param batchRequest 批量请求的对象
 @param responseArray 批量请求里的所有请求响应数据集合
 */
- (void)networkBatchRequest:(SANetworkBatchRequest *)batchRequest completedByResponseArray:(NSArray<SANetworkResponse *> *)responseArray;

@end

@class SANetworkRequest;
@protocol  SANetworkAccessoryProtocol;

/**
批量请求对象
 */
@interface SANetworkBatchRequest : NSObject


/**
 批量请求结果回调代理
 */
@property (nonatomic, weak) id<SANetworkBatchRequestResponseDelegate>delegate;


/**
 初始化批量请求。创建批量请求对象，只可使用此初始化方法

 @param requestArray 需要放在一起批量请求的请求对象集合
 @return 批量请求的对象
 */
- (instancetype)initWithRequestArray:(NSArray<SANetworkRequest *> *)requestArray;

/**
 *  @brief 开始网络批量请求
 */
- (void)startBatchRequest;

/**
 *  @brief 取消网络批量请求
 */
- (void)stopBatchRequest;

/**
 *  @brief 添加实现了SANetworkAccessoryProtocol的插件对象
 *
 *  @param accessoryDelegate 插件对象
 *  @warning 务必在启动请求之前添加插件。批量请求于请求插件完成协议状态 = 最后一个失败请求的状态
 */
- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate;
@end
