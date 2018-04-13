//
//  SANetworkRequest.m
//  SANetworkDemo
//
//  Created by 学宝 on 16/7/22.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
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
    [self accessoryDidStart];
}


- (void)stopRequestByStatus:(SANetworkStatus)status {
    [self stopRequestByStatus:status response:nil];
}

- (void)stopRequestByStatus:(SANetworkStatus)status response:(id)response {
    [[SANetworkAgent sharedInstance] removeRequest:self];
    [self accessoryFinishByStatus:status];
    [self accessoryFinishByStatus:status response:response];
}

- (void)dealloc {
    [[SANetworkAgent sharedInstance] removeRequest:self];
}

#pragma mark-
#pragma mark-Accessory

- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate {
    if (accessoryDelegate == nil)  return;

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

- (void)accessoryDidStart {
    for (id<SANetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidStart)]) {
            [accessory networkRequestAccessoryDidStart];
        }
    }
}

- (void)accessoryFinishByStatus:(SANetworkStatus)finishStatus {
    for (id<SANetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryByStatus:)]) {
            [accessory networkRequestAccessoryByStatus:finishStatus];
        }
    }
}

- (void)accessoryFinishByStatus:(SANetworkStatus)finishStatus response:(id)response {
    for (id<SANetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidEndByStatus:response:)]) {
            [accessory networkRequestAccessoryDidEndByStatus:finishStatus response:response];
        }
    }
}

@end
