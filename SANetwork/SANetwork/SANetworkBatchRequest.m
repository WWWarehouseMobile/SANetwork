//
//  SANetworkBatchRequest.m
//  ECM
//
//  Created by 学宝 on 16/1/18.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "SANetworkBatchRequest.h"
#import "SANetworkResponseProtocol.h"
#import "SANetworkRequest.h"
#import "SANetworkAgent.h"
#import "SANetworkResponse.h"

@interface SANetworkBatchRequest ()<SANetworkResponseProtocol>

@property (nonatomic) NSInteger completedCount;
@property (nonatomic, strong) NSArray<SANetworkRequest *> *requestArray;
@property (nonatomic, strong) NSMutableArray *accessoryArray;
@property (nonatomic, strong) NSMutableArray<SANetworkResponse *> *responseArray;

@end

@implementation SANetworkBatchRequest {
    SANetworkStatus _networkStatus;
}

- (instancetype)initWithRequestArray:(NSArray<SANetworkRequest *> *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = requestArray;
        _responseArray = [NSMutableArray array];
        _completedCount = -1;
    }
    return self;
}
- (void)startBatchRequest {
    if (self.completedCount > -1 ) {
        NSLog(@"批量请求正在进行，请勿重复启动  !");
        return;
    }
    _completedCount = 0;
    _networkStatus = SANetworkResponseDataSuccessStatus;
    
    [self accessoryWillStart];
    for (SANetworkRequest *networkRequest in self.requestArray) {
        networkRequest.responseDelegate = self;
        [[SANetworkAgent sharedInstance] addRequest:networkRequest];
    }
    [self accessoryDidStart];
}

- (void)stopBatchRequest {
    _delegate = nil;
    for (SANetworkRequest *networkRequest in self.requestArray) {
        [[SANetworkAgent sharedInstance] removeRequest:networkRequest];
    }
    [self accessoryFinishByStatus:SANetworkRequestCancelStatus];
}



#pragma mark-
#pragma mark-SANetworkResponseProtocol

- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response{
    self.completedCount++;
    [self.responseArray addObject:response];
    if (self.completedCount == self.requestArray.count) {
        [self networkBatchRequestCompleted];
    }
}

- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    self.completedCount++;
    [self.responseArray addObject:response];
    
    _networkStatus = response.networkStatus;
    if (self.completedCount == self.requestArray.count) {
        [self networkBatchRequestCompleted];
    }
}



- (void)networkBatchRequestCompleted{
    [self accessoryFinishByStatus:_networkStatus];
    if ([self.delegate respondsToSelector:@selector(networkBatchRequest:completedByResponseArray:)]) {
        [self.delegate networkBatchRequest:self completedByResponseArray:self.responseArray];
    }
    self.completedCount = -1;
}

- (void)dealloc {
    for (SANetworkRequest *networkRequest in self.requestArray) {
        [[SANetworkAgent sharedInstance] removeRequest:networkRequest];
    }
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

@end
