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

@interface SANetworkHUDAccessory : NSObject<SANetworkAccessoryProtocol>

- (instancetype)initWithShowInView:(UIView *)view text:(NSString *)text;

@end
