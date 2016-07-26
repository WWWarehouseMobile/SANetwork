//
//  SANetworkTestCase.h
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/22.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SANetwork.h"

//waitForExpectationsWithTimeout是等待时间，超过了就不再等待往下执行。
//#define WAIT do {\\
//[self expectationForNotification:@"SANetworkTestCase" object:nil handler:nil];\\
//[self waitForExpectationsWithTimeout:40 handler:nil];\\
//} while (0)
//
//#define NOTIFY \\
//[[NSNotificationCenter defaultCenter]postNotificationName:@"SANetworkTestCase" object:nil]

@interface SANetworkTestCase : XCTestCase<SANetworkResponseProtocol>

- (void)wait;

- (void)notify;

@end
