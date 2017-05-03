//
//  SANetworkConfig.m
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/21.
//  Copyright © 2016年 学宝工作室. All rights reserved.
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
    NSAssert(self.dataSource, @"必须提供dataSource绑定并实现servicesKindsOfNetwork方法，否则无法正常使用Service模块");
    if (self.serviceStorageDictionary[serviceIdentifier] == nil) {        
        if ([[self.dataSource servicesKindsOfNetwork] valueForKey:serviceIdentifier]) {
            NSObject<SANetworkServiceProtocol> *serviceObject = [[self.dataSource servicesKindsOfNetwork] valueForKey:serviceIdentifier];
            NSAssert([serviceObject conformsToProtocol:@protocol(SANetworkServiceProtocol)], @"你提供的Service没有遵循SANetworkServiceProtocol");
            return serviceObject;
        }else {
            NSAssert(NO, @"servicesKindsOfServiceFactory中无法找不到相匹配identifier");
        }
        return nil;
    }
    return self.serviceStorageDictionary[serviceIdentifier];
}
@end
