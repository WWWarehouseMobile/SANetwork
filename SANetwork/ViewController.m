//
//  ViewController.m
//  SANetwork
//
//  Created by ISCS01 on 16/3/25.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "TestSingRequest.h"
#import "SANetworkResponse.h"

@interface ViewController ()<SANetworkResponseProtocol>

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
    TestSingRequest *singRequest = [[TestSingRequest alloc] init];
    singRequest.responseDelegate = self;
    [singRequest startRequest];
}

- (BOOL)networkRequest:(SANetworkRequest *)networkRequest isCorrectWithResponse:(id)responseData {
    if ([responseData[@"code"] integerValue] == 1) {
        return YES;
    }
    return NO;
}

- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response {
//    NSLog(@"data = %@",response.contentData);
}
- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    NSLog(@"error : %@",response.message);
}
@end
