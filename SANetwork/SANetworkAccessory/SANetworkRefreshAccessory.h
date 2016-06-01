//
//  SANetworkRefreshAccessory.h
//  ECM
//
//  Created by 学宝 on 16/1/20.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkAccessoryProtocol.h"

@class MJRefreshComponent;
@interface SANetworkRefreshAccessory : NSObject<SANetworkAccessoryProtocol>

- (instancetype)initWithRefreshView:(MJRefreshComponent *)refreshView;

@end
