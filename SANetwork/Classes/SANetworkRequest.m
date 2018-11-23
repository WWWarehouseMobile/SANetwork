//
//  SANetworkRequest.m
//  SANetworkDemo
//
//  Created by 学宝 on 16/7/22.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import "SANetworkRequest.h"
#import "SANetworkAgent.h"
#import "SANetworkResponse.h"

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
    [[SANetworkAgent sharedInstance] removeRequest:self];
    SANetworkResponse *cancelResponse = [[SANetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:nil requestTag:self.tag networkStatus:SANetworkRequestCancelStatus];
    [self accessoryFinishByResponse:cancelResponse];
}

- (void)stopRequestByResponse:(SANetworkResponse *)response {
    [[SANetworkAgent sharedInstance] removeRequest:self];
    [self accessoryFinishByResponse:response];
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


- (void)accessoryFinishByResponse:(SANetworkResponse *)response {
    for (id<SANetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryByStatus:)]) {
            [accessory networkRequestAccessoryByStatus:response.networkStatus];
        }
        
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidEndByResponse:)]) {
            [accessory networkRequestAccessoryDidEndByResponse:response];
        }
    }
}

@end
