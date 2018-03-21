//
//  SATaobaoService.m
//  SANetworkDemo
//
//  Created by 学宝 on 2017/6/12.
//  Copyright © 2017年 WWWarehouse. All rights reserved.
//

#import "SATaobaoService.h"

@implementation SATaobaoService
- (NSString *)serviceApiBaseUrlString {
    return @"https://suggest.taobao.com/";
}

- (NSSet<NSString *> *)serviceResponseAcceptableContentTypes {
    return [NSSet setWithObjects:@"application/json",nil];
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

- (NSString *)responseContentDataKey {
    return @"result";
}
@end
