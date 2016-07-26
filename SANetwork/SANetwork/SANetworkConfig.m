//
//  SANetworkConfig.m
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/21.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import "SANetworkConfig.h"

@implementation SANetworkConfig

+ (SANetworkConfig *)sharedInstance {
    static SANetworkConfig *networkConfigInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkConfigInstance = [[SANetworkConfig alloc] init];
    });
    return networkConfigInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html",nil];
        _requestSerializerType = SARequestSerializerTypeHTTP;
        _responseSerializerType = SAResponseSerializerTypeJSON;
        _requestTimeoutInterval = 20.0f;
        _enableDebug = NO;
    }
    return self;
}

@end
