//
//  NetworkChainRequestTest.m
//  SANetworkDemo
//
//  Created by 詹学宝 on 2017/6/12.
//  Copyright © 2017年 学宝工作室. All rights reserved.
//

#import "SANetworkTestCase.h"
#import "ExpressRequest.h"
#import "TaobaoSuggestRequest.h"
#import "SANetworkChainRequest.h"
@interface NetworkChainRequestTest : SANetworkTestCase<SANetworkChainRequestResponseDelegate>

@end

@implementation NetworkChainRequestTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChainRequest {
    TaobaoSuggestRequest *suggestRequest = [[TaobaoSuggestRequest alloc] init];
    suggestRequest.query = @"iphone";
    SANetworkChainRequest *chainRequest = [[SANetworkChainRequest alloc] initWithRootNetworkRequest:suggestRequest];
    chainRequest.delegate = self;
    [chainRequest startChainRequest];
    [self wait];
}

- (__kindof SANetworkRequest *)networkChainRequest:(SANetworkChainRequest *)chainRequest nextNetworkRequestByNetworkRequest:(__kindof SANetworkRequest *)request finishedByResponse:(SANetworkResponse *)response {
    //这里的判断逻辑请求根据自己的业务逻辑灵活处理
    if (response != nil && [request isKindOfClass:[TaobaoSuggestRequest class]]) {
        ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
        expressRequest.type = @"yuantong";
        expressRequest.postId = @"881443775034378914";
        return expressRequest;
    }
    [self notify];
    return nil;
}

- (void)networkChainRequest:(SANetworkChainRequest *)chainRequest networkRequest:(__kindof SANetworkRequest *)request failedByResponse:(SANetworkResponse *)response {
    [self notify];
}

@end
