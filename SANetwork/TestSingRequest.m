//
//  TestSingRequest.m
//  SANetwork
//
//  Created by ISCS01 on 16/4/7.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "TestSingRequest.h"

@implementation TestSingRequest

- (NSString *)requestMethodName {
    return @"misc/singer/top";
}

- (SARequestMethod)requestMethod {
    return SARequestMethodGet;
}

- (BOOL)shouldCacheResponse {
    return YES;
}

- (Class)responseDataModelClass {
    return NSClassFromString(@"TestSingModel");
}

- (BOOL)isCorrectWithResponseData:(id)responseData {
    return YES;
}

@end
