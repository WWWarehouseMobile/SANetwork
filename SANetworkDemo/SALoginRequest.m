//
//  SALoginRequest.m
//  SmallAnimal
//
//  Created by 学宝 on 16/8/20.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SALoginRequest.h"

@implementation SALoginRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestParamSourceDelegate = self;
    }
    return self;
}

- (NSString *)requestMethodName {
    return @"http://192.168.6.25:8080/base/loginTest";
}

- (NSString *)serviceIdentifierKey {
    return nil;
}


- (BOOL)isCorrectWithResponseData:(id)responseData {
    return [responseData[@"code"] integerValue] == 0 ? YES : NO;
}

- (NSDictionary *)requestParamDictionary {
    return @{
             @"password" : self.password ?: @"",
             @"userId" : self.userId ?: @""
             };
}

@end
