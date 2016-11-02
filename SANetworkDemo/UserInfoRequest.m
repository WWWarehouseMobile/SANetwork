//
//  UserInfoRequest.m
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/27.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import "UserInfoRequest.h"

@implementation UserInfoRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestParamSourceDelegate = self;
    }
    return self;
}

- (NSString *)requestMethodName {
    return @"http://chengdu.fbbfc.com/api/getUserInfo";
}

- (BOOL)isCorrectWithResponseData:(id)responseData {
    if (responseData) {
        return YES;
    }
    return NO;
}

- (SARequestMethod)requestMethod {
    return SARequestMethodPost;
}

- (NSSet<NSString *> *)responseAcceptableContentTypes {
    return [NSSet setWithObject:@"text/html"];
}

- (NSDictionary *)requestParamDictionary {
    return @{
             @"mobile" : self.mobile,
             };
}

//- (SAResponseSerializerType)responseSerializerType {
//    return SAResponseSerializerTypeXMLParser;
//}

@end
