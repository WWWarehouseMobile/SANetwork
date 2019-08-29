//
//  SANetworkBatchRequest.h
//  ECM
//
//  Created by 学宝 on 16/1/18.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
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
/**
批量请求对象
 */
@interface SANetworkBatchRequest : NSObject

/*! 最大并发量 最大并发量不要乱写（5以内），一般以2~3为宜 默认3 */
@property (nonatomic, assign) NSInteger maxConcurrentCount;

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
 添加实现了DYNetworkAccessoryProtocol的插件对象
 @waring 在启动请求之前添加插件 可添加多个
 @param accessoryDelegate accessoryDelegate 插件对象
 */
- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate;




@end
