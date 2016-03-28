//
//  SANetworkRefreshAccessory.m
//  ECM
//
//  Created by 学宝 on 16/1/20.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkRefreshAccessory.h"
#import <MJRefresh/MJRefresh.h>

@interface SANetworkRefreshAccessory ()

@property (nonatomic, strong) MJRefreshComponent *refreshView;

@end

@implementation SANetworkRefreshAccessory

- (instancetype)initWithRefreshView:(MJRefreshComponent *)refreshView {
    self = [super init];
    if (self) {
        _refreshView = refreshView;
    }
    return self;
}

- (void)networkRequestAccessoryWillStart {
    if (![self.refreshView isRefreshing]) {
        [self.refreshView beginRefreshing];
    }
}

- (void)networkRequestAccessoryDidStop {
    [self.refreshView endRefreshing];
}

@end
