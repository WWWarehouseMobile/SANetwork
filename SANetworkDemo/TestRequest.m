//
//  TestRequest.m
//  SANetwork
//
//  Created by ISCS01 on 16/4/20.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "TestRequest.h"

@implementation TestRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.paramSourceDelegate = self;
    }
    return self;
}
- (NSString *)requestMethodName {
    return @"http://192.168.6.143:8080/originRefund/list";
}

- (SARequestMethod)requestMethod {
    return SARequestMethodPost;
}

- (BOOL)shouldCacheResponse {
    return NO;
}

- (NSDictionary *)requestParamDictionary {
    return @{
             @"currentPage": @1,
             @"pageSize": @20,
             @"sort": @"orderId &asc",
             @"filter": @[
                     @{
                         @"filed": @"shopId",
                         @"compare": @"equal",
                         @"value": @10,
                         @"datatype": @"number"
                         }
                     ]
             };
}

//- (Class)responseDataModelClass {
//    return NSClassFromString(@"BaseModel");
//}

- (BOOL)isCorrectWithResponseData:(id)responseData {
    return [responseData[@"code"]  integerValue] == 0 ? YES : NO;
}


@end
