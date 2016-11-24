//
//  SANetworkAccessoryProtocol.h
//  ECM
//
//  Created by 学宝 on 16/1/15.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SANetworkAccessoryFinishStatus) {
    SANetworkAccessoryFinishStatusSuccess,
    SANetworkAccessoryFinishStatusFailure,
    SANetworkAccessoryFinishStatusCancel,
    SANetworkAccessoryFinishStatusNotReachable,
};

/**
 *  @brief 请求插件协议
 */
@protocol SANetworkAccessoryProtocol <NSObject>

@optional

/**
 *  @brief 请求将要执行
 */
- (void)networkRequestAccessoryWillStart;

/**
 *  @brief 请求已经停止
 */
- (void)networkRequestAccessoryDidStop;

- (void)networkRequestAccessoryByStatus:(SANetworkAccessoryFinishStatus)accessoryStatus;
@end
