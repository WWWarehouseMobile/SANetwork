//
//  SANetworkTestCase.m
//  SANetworkDemo
//
//  Created by 学宝 on 16/7/22.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import "SANetworkTestCase.h"

@implementation SANetworkTestCase

- (void)setUp {
    [super setUp];
}

- (void)wait {
    do {
        [self expectationForNotification:@"SANetworkTestCaseNotification" object:nil handler:nil];
        [self waitForExpectationsWithTimeout:40 handler:nil];
    } while (0);
}

- (void)notify {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SANetworkTestCaseNotification" object:nil];
}

@end
