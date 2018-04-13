//
//  SANetworkHUDAccessory.m
//  ECM
//
//  Created by 学宝 on 16/1/20.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import "SANetworkHUDAccessory.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface SANetworkHUDAccessory ()
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation SANetworkHUDAccessory

- (instancetype)initWithShowInView:(UIView *)view text:(NSString *)text{
    self = [super init];
    if (self) {
        _hud = [[MBProgressHUD alloc] initWithView:view];
        _hud.removeFromSuperViewOnHide = YES;
        [view addSubview:_hud];
        if (text) {
            _hud.labelText = text;
        }
    }
    return self;
}

- (void)networkRequestAccessoryWillStart {
    [self.hud show:YES];
}

- (void)networkRequestAccessoryByStatus:(SANetworkStatus)networkStatus {
    switch (networkStatus) {
        case SANetworkNotReachableStatus:
            _hud.labelText = @"网络不可达";
            break;
        case SANetworkRequestCancelStatus:
            _hud.labelText = @"请求被取消了";
            break;
        case SANetworkResponseFailureStatus:
            _hud.labelText = @"请求失败了";
            break;
        case SANetworkResponseDataSuccessStatus:
            _hud.labelText = @"数据请求成功";
            break;
        case SANetworkRequestParamIncorrectStatus:
            _hud.labelText = @"请求参数错误";
            break;
        case SANetworkResponseDataIncorrectStatus:
            _hud.labelText = @"请求响应数据错误";
            break;
        case SANetworkResponseDataAuthenticationFailStatus:
            _hud.labelText = @"请求响应数据验证错误";
            break;
        default:
            break;
    }
    _hud.mode = MBProgressHUDModeText;
    [self.hud hide:YES afterDelay:1.7f];
}

- (void)networkRequestAccessoryDidEndByStatus:(SANetworkStatus)networkStatus response:(id)response {
    NSLog(@"networkRequestAccessoryDidEndByStatus:%@",response);
}
@end
