//
//  ExpressRequest.m
//  SANetwork
//
//  Created by ISCS01 on 16/3/31.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "ExpressRequest.h"

@implementation ExpressRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestParamSourceDelegate = self;
    }
    return self;
}

- (BOOL)isCorrectWithResponseData:(id)responseData {
    if (responseData) {
        return YES;
    }
    return NO;
}

- (NSDictionary *)requestParamDictionary {
    return @{
             @"type" : self.type,
             @"postid" : self.postId
             };
}

- (SARequestMethod)requestMethod {
    return SARequestMethodPost;
}

- (NSString *)requestMethodName {
    return @"query";
}

@end
