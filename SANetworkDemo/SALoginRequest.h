//
//  SALoginRequest.h
//  SmallAnimal
//
//  Created by 学宝 on 16/8/20.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkRequest.h"

@interface SALoginRequest : SANetworkRequest<SANetworkRequestConfigProtocol,SANetworkRequestParamSourceProtocol>

@property (nonatomic, strong, nonnull) NSString *userId;

@property (nonatomic, strong, nonnull) NSString *password;

@end
