//
//  ExpressRequest.h
//  SANetwork
//
//  Created by ISCS01 on 16/3/31.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkRequest.h"

@interface ExpressRequest : SANetworkRequest<SANetworkRequestConfigProtocol>
//SANetworkRequestParamSourceProtocol

@property (nonnull, nonatomic, copy) NSString *type;

@property (nonnull, nonatomic, copy) NSString *postId;

@end
