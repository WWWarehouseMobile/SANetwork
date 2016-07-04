//
//  ViewController.m
//  SANetwork
//
//  Created by ISCS01 on 16/3/25.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "TestSingRequest.h"
#import "SANetwork.h"
#import "TestRequest.h"
#import "BaseModel.h"
#import "TestModel.h"

@interface ViewController ()<SANetworkResponseProtocol,SANetworkParamSourceProtocol>

- (IBAction)pressSingButtonAction:(id)sender;

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

- (IBAction)pressSingButtonAction:(id)sender {
//    TestSingRequest *singRequest = [[TestSingRequest alloc] init];
//    singRequest.responseDelegate = self;
//    [singRequest startRequest];
    
    SANetworkHUDAccessory *hudAcc   = [[SANetworkHUDAccessory alloc] initWithShowInView:self.view text:@"Loading..."];
    TestRequest *testRequest        = [[TestRequest alloc] init];
    [testRequest addNetworkAccessoryObject:hudAcc];
//    testRequest.paramSourceDelegate = self;
    testRequest.responseDelegate    = self;
    [testRequest startRequest];
}

- (NSDictionary *)requestParamDictionary {
    return @{
             @"currentPage": @1,
             @"pageSize": @20,
             @"sort": @"orderId &asc",
             @"filter": @[
                     @{
                         @"filed": @"shopId",
                         @"compare": @"equal",
                         @"value": @10,
                         @"datatype": @"number"
                         }
                     ]
             };
}

- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response {
    NSLog(@"data = %@",response.contentData);
    if ([response.contentData isKindOfClass:[BaseModel class]]) {
        BaseModel *baseMode = (BaseModel *)response.contentData;
        baseMode.detailModelName = @"TestModel";
        [baseMode.contentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"objclass %@---%@",[obj class],[(TestModel *)obj receiverState]);
        }];
        NSLog(@"data = %@----array %@",response.contentData,baseMode.contentList);

    }
}
- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    NSLog(@"error : %@",response.message);
}
@end
