//
//  SANetworkChainRequest.m
//  ECM
//
//  Created by 学宝 on 16/1/18.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkChainRequest.h"
#import "SANetworkResponseProtocol.h"
#import "SANetworkRequest.h"


@interface SANetworkChainRequest ()<SANetworkResponseProtocol>

@property (nonatomic, strong) NSMutableArray *accessoryArray;

@property (nonatomic, strong) SANetworkRequest *currentNetworkRequest;

- (void)accessoryWillStart;
- (void)accessoryWillStop;
- (void)accessoryDidStop;

@end

@implementation SANetworkChainRequest

- (instancetype)initWithRootNetworkRequest:(SANetworkRequest *)networkRequest {
    self = [super init];
    if (self) {
        _currentNetworkRequest = networkRequest;
    }
    return self;
}

- (void)startChainRequest {
    [self accessoryWillStart];
    _currentNetworkRequest.responseDelegate = self;
    [self.currentNetworkRequest startRequest];
}

- (void)stopChainRequest {
    [self accessoryWillStop];
    [self.currentNetworkRequest stopRequest];
    [self accessoryDidStop];
}

- (void)dealloc {
    [self stopChainRequest];
}

#pragma mark-
#pragma mark-SANetworkResponseProtocol

- (BOOL)networkRequest:(SANetworkRequest *)networkRequest isCorrectWithResponse:(id)responseData {
    return [self.delegate networkChainRequest:self nextNetworkRequestByNetworkRequest:networkRequest isCorrectWithResponse:responseData];
}

- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response {
    if ([self.delegate respondsToSelector:@selector(networkChainRequest:nextNetworkRequestByNetworkRequest:finishedByResponse:)]) {
        SANetworkRequest *nextRequest = [self.delegate networkChainRequest:self nextNetworkRequestByNetworkRequest:networkRequest finishedByResponse:response];
        if (nextRequest != nil) {
            nextRequest.responseDelegate = self;
            [nextRequest startRequest];
            return;
        }
    }
    [self accessoryDidStop];
}

- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    [self accessoryWillStop];
    if ([self.delegate respondsToSelector:@selector(networkChainRequest:networkRequest:failedByResponse:)]) {
        [self.delegate networkChainRequest:self networkRequest:networkRequest failedByResponse:response];
    }
    [self accessoryDidStop];
}

#pragma mark-
#pragma mark-Accessory

- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate {
    if (!_accessoryArray) {
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
