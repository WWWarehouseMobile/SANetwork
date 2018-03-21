//
//  SANetworkTestCase.h
//  SANetworkDemo
//
//  Created by 学宝 on 16/7/22.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SANetwork/SANetwork.h>

//waitForExpectationsWithTimeout是等待时间，超过了就不再等待往下执行。
//#define WAIT do {\\
//[self expectationForNotification:@"SANetworkTestCase" object:nil handler:nil];\\
//[self waitForExpectationsWithTimeout:40 handler:nil];\\
//} while (0)
//
//#define NOTIFY \\
//[[NSNotificationCenter defaultCenter]postNotificationName:@"SANetworkTestCase" object:nil]

@interface SANetworkTestCase : XCTestCase

- (void)wait;

- (void)notify;

@end
