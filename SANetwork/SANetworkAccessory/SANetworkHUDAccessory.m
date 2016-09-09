//
//  SANetworkHUDAccessory.m
//  ECM
//
//  Created by 学宝 on 16/1/20.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
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

- (void)networkRequestAccessoryDidStop {
    [self.hud hide:YES afterDelay:0.3f];
}

@end
