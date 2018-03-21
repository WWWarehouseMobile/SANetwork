//
//  SANetworkRefreshAccessory.h
//  ECM
//
//  Created by 学宝 on 16/1/20.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkAccessoryProtocol.h"

@class MJRefreshComponent;

/**
 定制的Refresh请求插件
 */
@interface SANetworkRefreshAccessory : NSObject<SANetworkAccessoryProtocol>


/**
  初始化Refresh请求插件

 @param refreshView 刷新的view
 @return Refresh请求插件对象
 */
- (instancetype)initWithRefreshView:(MJRefreshComponent *)refreshView;

@end
