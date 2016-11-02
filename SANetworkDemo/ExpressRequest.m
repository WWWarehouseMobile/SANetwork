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
//        self.requestParamSourceDelegate = self;
    }
    return self;
}

- (NSString *)requestMethodName {
    return @"http://192.168.6.24:8080/base/getCaptcha";
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

- (SARequestSerializerType)requestSerializerType {
    return SARequestSerializerTypeHTTP;
}
- (SAResponseSerializerType)responseSerializerType {
    return SAResponseSerializerTypeImage;
}
//- (NSDictionary *)requestParamDictionary {
//    return @{
//             @"type" : self.type,
//             @"postid" : self.postId
//             };
//}

@end
