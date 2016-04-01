//
//  TestViewController.m
//  SANetwork
//
//  Created by ISCS01 on 16/3/31.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "TestViewController.h"
#import "SANetwork.h"
#import "SANetworkAgent.h"
#import "ExpressRequest.h"

@interface TestViewController ()<SANetworkResponseProtocol>
@property (weak, nonatomic) IBOutlet UITextField *typeTextField;
@property (weak, nonatomic) IBOutlet UITextField *postidTextField;
@property (weak, nonatomic) IBOutlet UITextView *dataTextView;
- (IBAction)pressQueryButtonAction:(id)sender;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (BOOL)networkRequest:(SANetworkRequest *)networkRequest isCorrectWithResponse:(id)responseData {
    /**
     *  可以写入对返回数据的检测
     */
    return YES;
}

- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response {
    NSLog(@"data: %@",response.responseData);
//    NSDictionary
//    self.dataTextView.text = [response.contentData stringValue];
}

- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressQueryButtonAction:(id)sender {
    ExpressRequest *expressRequest = [[ExpressRequest alloc] initWithType:self.typeTextField.text postId:self.postidTextField.text];
    expressRequest.responseDelegate = self;
    [expressRequest startRequest];
}
@end
