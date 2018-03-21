//
//  SANetworkConfig.m
//  SANetworkDemo
//
//  Created by 学宝 on 16/7/21.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import "SANetworkConfig.h"

@interface SANetworkConfig ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSObject<SANetworkServiceProtocol> *> *serviceStorageDictionary;

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
        _enableDebug = NO;
    }
    return self;
}

- (NSMutableDictionary<NSString *, NSObject<SANetworkServiceProtocol> *> *)serviceStorageDictionary {
    if (_serviceStorageDictionary == nil) {
        _serviceStorageDictionary = [[NSMutableDictionary alloc] init];
    }
    return _serviceStorageDictionary;
}

- (NSObject<SANetworkServiceProtocol> *)serviceObjectWithServiceIdentifier:(NSString *)serviceIdentifier {
    if (self.serviceStorageDictionary[serviceIdentifier] == nil) {
        NSAssert(NO, @"无法找到 %@ 相匹配的服务对象", serviceIdentifier);
        return nil;
    }
    return self.serviceStorageDictionary[serviceIdentifier];
}

- (void)registerServiceObject:(NSObject<SANetworkServiceProtocol> *)serviceObject serviceIdentifier:(NSString *)serviceIdentifier {
    if (serviceObject == nil)   return;
    
    NSAssert([serviceObject conformsToProtocol:@protocol(SANetworkServiceProtocol)], @"你提供的Service没有遵循SANetworkServiceProtocol");
    self.serviceStorageDictionary[serviceIdentifier] = serviceObject;
}
@end
