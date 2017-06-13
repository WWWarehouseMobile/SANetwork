//
//  SANetworkServiceTest.m
//  SANetworkDemo
//
//  Created by 詹学宝 on 2017/4/28.
//  Copyright © 2017年 浙江网仓科技有限公司. All rights reserved.
//

#import "SAExpressService.h"

@implementation SAExpressService

- (NSString *)serviceApiBaseUrlString {
    return @"http://www.kuaidi100.com";
}

- (NSSet<NSString *> *)serviceResponseAcceptableContentTypes {
    return [NSSet setWithObjects:@"application/json",@"text/html",nil];
}

- (SARequestSerializerType)serviceRequestSerializerType {
    return SARequestSerializerTypeHTTP;
}

- (SAResponseSerializerType)serviceResponseSerializerType {
    return SAResponseSerializerTypeJSON;
}

- (NSDictionary<NSString *,NSString *> *)serviceBaseHTTPRequestHeaders {
    return nil;
}

- (NSDictionary<NSString *,NSString *> *)serviceBaseParamSource {
    return nil;
}

- (BOOL)serviceBaseAuthenticationWithResonse:(id)response {
    return YES;
}

- (NSTimeInterval)serviceRequestTimeoutInterval {
    return 20.0f;
}

/*******以下协议的设定用于服务端返回数据的第一层格式统一，设定后，便于更深一层的取到数据 *********/

- (NSString *)responseMessageKey {
    return @"message";
}

- (NSString *)responseCodeKey {
    return nil;
}

- (NSString *)responseContentDataKey {
    return @"data";
}

@end
