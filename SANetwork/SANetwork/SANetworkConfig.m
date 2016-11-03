//
//  SANetworkConfig.m
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/21.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import "SANetworkConfig.h"

static inline NSString *kAcceptableContentTypesKey(SAResponseSerializerType responseSerializerType) {
    return [NSString stringWithFormat:@"com.sanetwork.responseSerializerType-%ld",(long)responseSerializerType];
}

@interface SANetworkConfig ()
@property (nonatomic, strong) NSMutableDictionary *acceptableContentTypesDict;
@end
@implementation SANetworkConfig {
}

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
        _requestSerializerType = SARequestSerializerTypeHTTP;
        _responseSerializerType = SAResponseSerializerTypeJSON;
        _requestTimeoutInterval = 20.0f;
        _enableDebug = NO;
        _acceptableContentTypesDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setAcceptableContentTypes:(NSSet<NSString *> *)acceptableContentTypes forResponseSerializerType:(SAResponseSerializerType)responseSerializerType {
    if ([acceptableContentTypes count]) {
        [self.acceptableContentTypesDict setObject:acceptableContentTypes forKey:kAcceptableContentTypesKey(responseSerializerType)];
    }
}

- (NSSet<NSString *> *)acceptableContentTypesForResponseSerializerType:(SAResponseSerializerType)responseSerializerType {
    return self.acceptableContentTypesDict[kAcceptableContentTypesKey(responseSerializerType)];
}
@end
