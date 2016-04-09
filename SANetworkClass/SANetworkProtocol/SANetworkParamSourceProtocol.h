//
//  SANetworkParamSourceProtocol.h
//  SANetwork
//
//  Created by ISCS01 on 16/4/8.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SANetworkParamSourceProtocol <NSObject>

@required
/**
 *  @brief 请求所需要的参数
 *
 *  @return 参数字典
 */

- (NSDictionary *)requestParamDictionary;

@end
