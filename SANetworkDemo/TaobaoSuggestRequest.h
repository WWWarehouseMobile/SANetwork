//
//  TaobaoSuggestRequest.h
//  SANetworkDemo
//
//  Created by 詹学宝 on 2017/6/12.
//  Copyright © 2017年 学宝工作室. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkRequest.h"

@interface TaobaoSuggestRequest : SANetworkRequest<SANetworkRequestConfigProtocol>
/**查询条件*/
@property (nonatomic, strong) NSString *query;
@end
