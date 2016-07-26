//
//  ViewController.m
//  SANetwork
//
//  Created by ISCS01 on 16/3/25.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "SANetwork.h"
#import "SANetworkHUDAccessory.h"
#import "ExpressRequest.h"

#import "TaobaoMobileRequest.h"

@interface ViewController ()<SANetworkResponseProtocol,SANetworkBatchRequestResponseDelegate,SANetworkChainRequestResponseDelegate>

@property (nonatomic, strong) SANetworkChainRequest *chainRequest;

@property (nonatomic, strong) SANetworkBatchRequest *batchRequest;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pressSingleRequest:(id)sender {
    TaobaoMobileRequest *mobileRequest = [[TaobaoMobileRequest alloc] init];
    mobileRequest.responseDelegate = self;
    mobileRequest.mobile = @"13173610819";
    [mobileRequest startRequest];
}

- (IBAction)pressChainRequest:(id)sender {
    TaobaoMobileRequest *mobileRequest = [[TaobaoMobileRequest alloc] init];
    mobileRequest.mobile = @"13173610819";
    SANetworkChainRequest *chainRequest = [[SANetworkChainRequest alloc] initWithRootNetworkRequest:mobileRequest];
    chainRequest.delegate = self;
    [chainRequest startChainRequest];
    _chainRequest = chainRequest;
}

- (IBAction)pressBatchRequest:(id)sender {
    TaobaoMobileRequest *mobileRequest = [[TaobaoMobileRequest alloc] init];
    mobileRequest.mobile = @"13173610819";
    
    ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
    expressRequest.type = @"yuantong";
    expressRequest.postId = @"881443775034378914";
    
    SANetworkBatchRequest *batchRequest = [[SANetworkBatchRequest alloc] initWithRequestArray:@[mobileRequest,expressRequest]];
    [batchRequest startBatchRequest];
    _batchRequest = batchRequest;
}


#pragma mark-
#pragma mark- SANetworkResponseProtocol
- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response {
    NSLog(@"data = %@  \n result: %@",response.responseData,[[NSString alloc] initWithData:response.responseData encoding:NSUTF8StringEncoding]);

}
- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    NSLog(@"error : %@",response.responseMessage);
}

#pragma mark-
#pragma mark- SANetworkChainRequestResponseDelegate
- (__kindof SANetworkRequest *)networkChainRequest:(SANetworkChainRequest *)chainRequest nextNetworkRequestByNetworkRequest:(__kindof SANetworkRequest *)request finishedByResponse:(SANetworkResponse *)response {
    //这里的判断逻辑请求根据自己的业务逻辑灵活处理
    if (response != nil && [request isKindOfClass:[TaobaoMobileRequest class]]) {
        ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
        expressRequest.type = @"yuantong";
        expressRequest.postId = @"881443775034378914";
        return expressRequest;
    }
    return nil;
}

- (void)networkChainRequest:(SANetworkChainRequest *)chainRequest networkRequest:(__kindof SANetworkRequest *)request failedByResponse:(SANetworkResponse *)response {
    NSLog(@"%@ error : %@",NSStringFromClass(request.class), response.responseMessage);
}

#pragma mark-
#pragma mark- SANetworkBatchRequestResponseDelegate

- (void)networkBatchRequest:(SANetworkBatchRequest *)batchRequest completedByResponseArray:(NSArray<SANetworkResponse *> *)responseArray {
    NSLog(@"responseArray: %@",responseArray);
}
@end
