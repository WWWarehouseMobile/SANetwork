//
//  SAViewController.m
//  SANetwork
//
//  Created by XB-Paul on 07/08/2017.
//  Copyright (c) 2017 XB-Paul. All rights reserved.
//

#import "SAViewController.h"
#import <SANetwork/SANetwork.h>
#import "SANetworkHUDAccessory.h"
#import "ExpressRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "TaobaoSuggestRequest.h"

@interface SAViewController ()<SANetworkResponseProtocol,SANetworkBatchRequestResponseDelegate,SANetworkChainRequestResponseDelegate>

@property (nonatomic, strong) SANetworkChainRequest *chainRequest;

@property (nonatomic, strong) SANetworkBatchRequest *batchRequest;

@end

@implementation SAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(af_reachabilityDidChangeWithNofitication:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)af_reachabilityDidChangeWithNofitication:(NSNotification *)notificaiton {
    NSLog(@"userInfo:%@",notificaiton.userInfo);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressSingleRequest:(id)sender {
    SANetworkHUDAccessory *hudAccessory = [[SANetworkHUDAccessory alloc] initWithShowInView:self.view text:@"Request Loading..."];
    TaobaoSuggestRequest *suggestRequest = [[TaobaoSuggestRequest alloc] init];
    suggestRequest.query = @"iphone";
    suggestRequest.tag = 102;
    suggestRequest.responseDelegate = self;
    [suggestRequest addNetworkAccessoryObject:hudAccessory];
    
    for (NSInteger i = 0; i<10; i++) {

        [suggestRequest startRequest];
    }
}

- (IBAction)pressChainRequest:(id)sender {
    SANetworkHUDAccessory *hudAccessory = [[SANetworkHUDAccessory alloc] initWithShowInView:self.view text:@"Chain Loading..."];
    TaobaoSuggestRequest *suggestRequest = [[TaobaoSuggestRequest alloc] init];
    suggestRequest.query = @"iphone";

    SANetworkChainRequest *chainRequest = [[SANetworkChainRequest alloc] initWithRootNetworkRequest:suggestRequest];
    chainRequest.delegate = self;
    [chainRequest addNetworkAccessoryObject:hudAccessory];
    [chainRequest startChainRequest];
    _chainRequest = chainRequest;
}

- (IBAction)pressBatchRequest:(id)sender {
    TaobaoSuggestRequest *suggestRequest = [[TaobaoSuggestRequest alloc] init];
    suggestRequest.query = @"iphone";
    
    ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
    expressRequest.type = @"yuantong";
    expressRequest.postId = @"881443775034378914";
    
    SANetworkBatchRequest *batchRequest = [[SANetworkBatchRequest alloc] initWithRequestArray:@[suggestRequest,expressRequest]];
    [batchRequest startBatchRequest];
    _batchRequest = batchRequest;
}

#pragma mark-
#pragma mark- SANetworkResponseProtocol
- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response {
    //    NSLog(@"data = %@  \n",response.responseData);
    if (networkRequest.tag == 101) {
        NSLog(@"contentData:%@",response.responseContentData);
    }
}
- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    //    NSLog(@"error : %@",response.responseMessage);
}

#pragma mark-
#pragma mark- SANetworkChainRequestResponseDelegate
- (__kindof SANetworkRequest *)networkChainRequest:(SANetworkChainRequest *)chainRequest nextNetworkRequestByNetworkRequest:(__kindof SANetworkRequest *)request finishedByResponse:(SANetworkResponse *)response {
    //这里的判断逻辑请求根据自己的业务逻辑灵活处理
    if (response != nil && [request isKindOfClass:[TaobaoSuggestRequest class]]) {
        ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
        expressRequest.type = @"yuantong";
        expressRequest.postId = @"881443775034378914";
        return expressRequest;
    }
    return nil;
}

- (void)networkChainRequest:(SANetworkChainRequest *)chainRequest networkRequest:(__kindof SANetworkRequest *)request failedByResponse:(SANetworkResponse *)response {
    //    NSLog(@"%@ error : %@",NSStringFromClass(request.class), response.responseMessage);
}

#pragma mark-
#pragma mark- SANetworkBatchRequestResponseDelegate

- (void)networkBatchRequest:(SANetworkBatchRequest *)batchRequest completedByResponseArray:(NSArray<SANetworkResponse *> *)responseArray {
    //    NSLog(@"responseArray: %@",responseArray);
}

- (void)dealloc {
    NSLog(@"SAViewController -- dealloc");
}
@end
