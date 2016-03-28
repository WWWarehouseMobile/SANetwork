//
//  SANetworkRequest.m
//  ECM
//
//  Created by 学宝 on 16/1/16.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkRequest.h"
#import "SANetworkAgent.h"


NSString *const kClassNameKey = @"iclass";
NSString *const kMethodNameKey = @"imethod";
NSString *const kEMUserIdKey = @"defaultUsername";
NSString *const kEMUserPasswordKey = @"defaultPassword";

@interface SANetworkRequest ()
@property (nonatomic, weak) id <SANetworkConfigProtocol> configProtocol;

@property (nonatomic, strong) NSMutableArray *accessoryArray;


@end

@implementation SANetworkRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(SANetworkConfigProtocol)]) {
            _configProtocol = (id <SANetworkConfigProtocol>)self;
        }else{
            NSAssert(NO, @"子类必须实现SANetworkConfigProtocol协议");
        }
    }
    return self;
}

- (void)startRequest {
    [self accessoryWillStart];
    [[SANetworkAgent sharedInstance] addRequest:self];
}


- (void)stopRequest {
    [self accessoryWillStop];
    [[SANetworkAgent sharedInstance] removeRequest:self];
    [self accessoryDidStop];
}

- (void)dealloc {
    [self stopRequest];
}


#pragma mark-
#pragma mark-Accessory

- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate {
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    [self.accessoryArray addObject:accessoryDelegate];
}

- (void)accessoryWillStart {
    for (id<SANetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryWillStart)]) {
            [accessory networkRequestAccessoryWillStart];
        }
    }
}

- (void)accessoryWillStop {
    for (id<SANetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryWillStop)]) {
            [accessory networkRequestAccessoryWillStop];
        }
    }
}

- (void)accessoryDidStop {
    for (id<SANetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidStop)]) {
            [accessory networkRequestAccessoryDidStop];
        }
    }
}
@end
