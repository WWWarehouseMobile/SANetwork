//
//  SANetworkChainRequest.m
//  ECM
//
//  Created by 学宝 on 16/1/18.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import "SANetworkChainRequest.h"
#import "SANetworkRequest.h"
#import "SANetworkResponseProtocol.h"
#import "SANetworkAgent.h"
#import "SANetworkResponse.h"

@interface SANetworkChainRequest ()<SANetworkResponseProtocol>

@property (nonatomic, strong) NSMutableArray *accessoryArray;
@property (nonatomic, strong) SANetworkRequest *currentNetworkRequest;

@end

@implementation SANetworkChainRequest

- (instancetype)initWithRootNetworkRequest:(__kindof SANetworkRequest *)networkRequest {
    self = [super init];
    if (self) {
        _currentNetworkRequest = networkRequest;
    }
    return self;
}

- (void)startChainRequest {
    [self accessoryWillStart];
    _currentNetworkRequest.responseDelegate = self;
    [[SANetworkAgent sharedInstance] addRequest:self.currentNetworkRequest];
    [self accessoryDidStart];
}

- (void)stopChainRequest {
    _delegate = nil;
    [[SANetworkAgent sharedInstance] removeRequest:self.currentNetworkRequest];
    SANetworkResponse *cancelResponse = [[SANetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:nil requestTag:self.currentNetworkRequest.tag networkStatus:SANetworkRequestCancelStatus];
    [self accessoryFinishByResponse:cancelResponse];
}

- (void)dealloc {
    [[SANetworkAgent sharedInstance] removeRequest:self.currentNetworkRequest];
}


#pragma mark-
#pragma mark-SANetworkResponseProtocol

- (void)networkRequest:(__kindof SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response {
    if ([self.delegate respondsToSelector:@selector(networkChainRequest:nextNetworkRequestByNetworkRequest:finishedByResponse:)]) {
        SANetworkRequest *nextRequest = [self.delegate networkChainRequest:self nextNetworkRequestByNetworkRequest:networkRequest finishedByResponse:response];
        if (nextRequest != nil) {
            nextRequest.responseDelegate = self;
            [nextRequest startRequest];
            self.currentNetworkRequest = nextRequest;
            return;
        }
    }
    [self accessoryFinishByResponse:response];
}

- (void)networkRequest:(__kindof SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    [self accessoryFinishByResponse:response];
    if ([self.delegate respondsToSelector:@selector(networkChainRequest:networkRequest:failedByResponse:)]) {
        [self.delegate networkChainRequest:self networkRequest:networkRequest failedByResponse:response];
    }
}

#pragma mark-
#pragma mark-Accessory

- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate {
    if (accessoryDelegate == nil)  return;

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
