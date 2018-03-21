//
//  TaobaoSuggestRequest.h
//  SANetworkDemo
//
//  Created by 学宝 on 2017/6/12.
//  Copyright © 2017年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SANetwork/SANetwork.h>

@interface TaobaoSuggestRequest : SANetworkRequest<SANetworkRequestConfigProtocol>
/**查询条件*/
@property (nonatomic, strong) NSString *query;
@end
