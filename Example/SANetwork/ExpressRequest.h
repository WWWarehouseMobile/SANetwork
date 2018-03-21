//
//  ExpressRequest.h
//  SANetwork
//
//  Created by 学宝 on 16/3/31.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <SANetwork/SANetwork.h>

@interface ExpressRequest : SANetworkRequest<SANetworkRequestConfigProtocol>
//

@property (nonnull, nonatomic, copy) NSString *type;

@property (nonnull, nonatomic, copy) NSString *postId;

@end
