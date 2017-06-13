//
//  SANetworkHUDAccessory.h
//  ECM
//
//  Created by 学宝 on 16/1/20.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SANetworkAccessoryProtocol.h"

/**
 定制的MBProgressHUD请求插件
 */
@interface SANetworkHUDAccessory : NSObject<SANetworkAccessoryProtocol>


/**
 初始化MBProgressHUD请求插件

 @param view hud需要显示在哪个view上
 @param text hud显示的文字信息
 @return MBProgressHUD请求插件对象
 */
- (instancetype)initWithShowInView:(UIView *)view text:(NSString *)text;

@end
