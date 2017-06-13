//
//  NetworkSingleRequestTest.m
//  SANetworkDemo
//
//  Created by 詹学宝 on 2017/6/12.
//  Copyright © 2017年 学宝工作室. All rights reserved.
//

#import "SANetworkTestCase.h"
#import "ExpressRequest.h"
#import "TaobaoSuggestRequest.h"

@interface NetworkSingleRequestTest : SANetworkTestCase<SANetworkResponseProtocol>

@end

@implementation NetworkSingleRequestTest

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
    expressRequest.type = @"yuantong";
    expressRequest.postId = @"881443775034378914";
    expressRequest.tag = 101;
    expressRequest.responseDelegate = self;
    [expressRequest startRequest];
    [self wait];
}

- (void)testTaobaoSuggestRequest {
    TaobaoSuggestRequest *suggestRequest = [[TaobaoSuggestRequest alloc] init];
    suggestRequest.query = @"imac";
    suggestRequest.tag = 102;
    suggestRequest.responseDelegate = self;
    [suggestRequest startRequest];
    [self wait];
}

- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    switch (networkRequest.tag) {
        case 101:
            XCTAssert(NO, @"快递查询请求失败");
            break;
        case 102:
            XCTAssert(NO, @"淘宝关键词建议接口调用失败");
            break;
        default:
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
            XCTAssertNotNil(response.responseContentData,@"用户信息查询无数据");
            break;
        case 103:
            break;
        default:
            break;
    }
    [self notify];
}


@end
