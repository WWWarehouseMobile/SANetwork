//
//  SANetworkRequestParamSourceProtocol.h
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/21.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SANetworkRequestParamSourceProtocol <NSObject>

@required
/**
 *  @brief 请求所需要的参数
 *
 *  @return 参数字典
 */

- (NSDictionary *)requestParamDictionary;

@end
