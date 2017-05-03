//
//  SATestRequestCase.m
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/25.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import "SANetworkTestCase.h"
#import "ExpressRequest.h"
#import "BaiFuBaoRequest.h"
#import "SALoginRequest.h"

@interface SATestRequestCase : SANetworkTestCase

@end

@implementation SATestRequestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExpressResquest {
    ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
    expressRequest.tag = 101;
    expressRequest.responseDelegate = self;
    expressRequest.type = @"yuantong";
    expressRequest.postId = @"881443775034378914";
    [expressRequest startRequest];
    [self wait];
}

- (void)testSALoginRequest {
    SALoginRequest *loginRequest = [[SALoginRequest alloc] init];
    loginRequest.userId = @"1000294";
    loginRequest.password = @"1";
    loginRequest.tag = 103;
    loginRequest.responseDelegate = self;
    [loginRequest startRequest];
    [self wait];
}

- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    switch (networkRequest.tag) {
        case 101:
            XCTAssert(NO, @"快递查询请求失败");
            break;
        case 102:
            XCTAssert(NO, @"用户信息查询请求失败");
            break;
        default:
            XCTAssert(NO, @"用户登录请求失败");
            break;
    }
    [self notify];
}

- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response {
    switch (networkRequest.tag) {
        case 101:
            XCTAssertNotNil(response.responseData,@"快递查询无数据");
            break;
        case 102:
            XCTAssertNotNil(response.responseData,@"用户信息查询无数据");
            break;
        case 103:
            XCTAssertNotNil(response.responseData,@"用户登录无数据");

            break;
        default:
            break;
    }
    [self notify];
}

- (void)testUserInfoRequest {
    BaiFuBaoRequest *userInfoRequest = [[BaiFuBaoRequest alloc] init];
    userInfoRequest.tag = 102;
    userInfoRequest.responseDelegate = self;
    userInfoRequest.mobile = @"13173610819";
    [userInfoRequest startRequest];
    [self wait];
}

@end
