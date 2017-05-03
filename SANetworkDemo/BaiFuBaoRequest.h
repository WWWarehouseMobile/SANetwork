//
//  UserInfoRequest.h
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/27.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import "SANetworkRequest.h"

@interface BaiFuBaoRequest : SANetworkRequest<SANetworkRequestConfigProtocol,SANetworkRequestParamSourceProtocol>
@property (nonnull, nonatomic, strong) NSString *mobile;
@end
