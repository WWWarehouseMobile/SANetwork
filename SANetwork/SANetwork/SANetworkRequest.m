//
//  SANetworkRequest.m
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/22.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import "SANetworkRequest.h"
#import "SANetworkAgent.h"

@interface SANetworkRequest ()
@property (nonatomic, weak) id <SANetworkRequestConfigProtocol> requestConfigProtocol;

@property (nonatomic, strong) NSMutableArray *accessoryArray;


@end

@implementation SANetworkRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(SANetworkRequestConfigProtocol)]) {
            _requestConfigProtocol = (id <SANetworkRequestConfigProtocol>)self;
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


- (void)accessoryDidStop {
    for (id<SANetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidStop)]) {
            [accessory networkRequestAccessoryDidStop];
        }
    }
}

@end
