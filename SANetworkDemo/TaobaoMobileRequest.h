//
//  TaobaoMobileRequest.h
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/25.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import "SANetworkRequest.h"

@interface TaobaoMobileRequest : SANetworkRequest<SANetworkRequestConfigProtocol,SANetworkRequestParamSourceProtocol>
@property (nonnull, nonatomic, strong) NSString *mobile;
@end
