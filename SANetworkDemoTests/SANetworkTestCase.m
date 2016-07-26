//
//  SANetworkTestCase.m
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/22.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import "SANetworkTestCase.h"
#import <AFNetworking/AFNetworking.h>

@implementation SANetworkTestCase

- (void)setUp {
    [super setUp];
}

- (void)wait {
    do {
        [self expectationForNotification:@"SANetworkTestCase" object:nil handler:nil];
        [self waitForExpectationsWithTimeout:40 handler:nil];
    } while (0);
}

- (void)notify {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SANetworkTestCase" object:nil];
}

@end
