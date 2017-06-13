//
//  NetworkBatchRequestTest.m
//  SANetworkDemo
//
//  Created by 詹学宝 on 2017/6/12.
//  Copyright © 2017年 学宝工作室. All rights reserved.
//

#import "SANetworkTestCase.h"
#import "ExpressRequest.h"
#import "TaobaoSuggestRequest.h"
#import "SANetworkBatchRequest.h"

@interface NetworkBatchRequestTest : SANetworkTestCase<SANetworkBatchRequestResponseDelegate>

@end

@implementation NetworkBatchRequestTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBatchRequest {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    TaobaoSuggestRequest *suggestRequest = [[TaobaoSuggestRequest alloc] init];
    suggestRequest.query = @"iphone";
    
    ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
    expressRequest.type = @"yuantong";
    expressRequest.postId = @"881443775034378914";
    
    SANetworkBatchRequest *batchRequest = [[SANetworkBatchRequest alloc] initWithRequestArray:@[suggestRequest,expressRequest]];
    batchRequest.delegate = self;
    [batchRequest startBatchRequest];
    [self  wait];
}

#pragma mark-
#pragma mark- SANetworkBatchRequestResponseDelegate

- (void)networkBatchRequest:(SANetworkBatchRequest *)batchRequest completedByResponseArray:(NSArray<SANetworkResponse *> *)responseArray {
    //    NSLog(@"responseArray: %@",responseArray);
    [self notify];
}
@end
