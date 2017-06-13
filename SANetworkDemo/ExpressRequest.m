//
//  ExpressRequest.m
//  SANetwork
//
//  Created by 学宝 on 16/3/31.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "ExpressRequest.h"

@implementation ExpressRequest

- (NSString *)requestMethodName {
    return @"query";
}

- (NSString *)serviceIdentifierKey {
    return @"kuaidiServiceKey";
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

@end
