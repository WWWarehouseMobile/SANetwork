//
//  TaobaoMobileRequest.m
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/25.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import "TaobaoMobileRequest.h"

@implementation TaobaoMobileRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestParamSourceDelegate = self;
    }
    return self;
}

- (NSString *)requestMethodName {
    return @"http://tcc.taobao.com/cc/json/mobile_tel_segment.htm";
}

- (SARequestMethod)requestMethod {
    return SARequestMethodPost;
}

- (SAResponseSerializerType)responseSerializerType {
    return SAResponseSerializerTypeHTTP;
}

- (BOOL)isCorrectWithResponseData:(id)responseData {
    return responseData ? YES : NO;
}

- (NSDictionary *)requestParamDictionary {
    return @{
             @"tel" : self.mobile
             };
}
@end
