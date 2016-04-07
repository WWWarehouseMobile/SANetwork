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

@interface SANetworkBatchRequest ()<SANetworkResponseProtocol>

@property (nonatomic) NSInteger completedCount;

@property (nonatomic, strong) NSArray<SANetworkRequest *> *requestArray;

@property (nonatomic, strong) NSMutableArray *accessoryArray;

@property (nonatomic, strong) NSMutableArray<SANetworkResponse *> *responseArray;

- (void)accessoryWillStart;
- (void)accessoryWillStop;
- (void)accessoryDidStop;

@end

@implementation SANetworkBatchRequest

- (instancetype)initWithRequestArray:(NSArray<SANetworkRequest *> *)requestArray{
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        _responseArray = [NSMutableArray array];
        _completedCount = 0;
        _isContinueByFailResponse = YES;
    }
    return self;
}

- (void)startBatchRequest {
    if (self.completedCount > 0 ) {
        NSLog(@"批量请求正在进行，请勿重复启动  !");
        return;
    }
    
    [self accessoryWillStart];
    for (SANetworkRequest *networkRequest in self.requestArray) {
        networkRequest.responseDelegate = self;
        [networkRequest startRequest];
    }
}

- (void)stopBatchRequest {
    [self accessoryWillStop];
    _delegate = nil;
    for (SANetworkRequest *networkRequest in self.requestArray) {
        [networkRequest stopRequest];
    }
    [self accessoryDidStop];
}



#pragma mark-
#pragma mark-SANetworkResponseProtocol

- (BOOL)networkRequest:(SANetworkRequest *)networkRequest isCorrectWithResponse:(id)responseData {
    if ([self.delegate respondsToSelector:@selector(networkBatchRequest:networkRequest:isCorrectWithResponse:)]) {
        return [self.delegate networkBatchRequest:self networkRequest:networkRequest isCorrectWithResponse:responseData];
    }
    return  YES;
}

- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response{
    self.completedCount++;
    [self.responseArray addObject:response];
    if (self.completedCount == self.requestArray.count) {
        [self accessoryWillStop];
        [self networkBatchRequestCompleted];
    }
}

- (void)networkRequest:(SANetworkRequest *)networkRequest failedByResponse:(SANetworkResponse *)response {
    [self.responseArray addObject:response];

    if (self.isContinueByFailResponse) {
        self.completedCount++;
        if (self.completedCount == self.requestArray.count) {
            [self accessoryWillStop];
            [self networkBatchRequestCompleted];
        }
    }else{
        [self accessoryWillStop];
        for (SANetworkRequest *networkRequest in self.requestArray) {
            [networkRequest stopRequest];
        }
        [self networkBatchRequestCompleted];
    }
}



- (void)networkBatchRequestCompleted{
        if ([self.delegate respondsToSelector:@selector(networkBatchRequest:completedByResponseArray:)]) {
            [self.delegate networkBatchRequest:self completedByResponseArray:self.responseArray];
        }
    [self accessoryDidStop];
    self.completedCount = 0;
}

- (void)dealloc {
    [self stopBatchRequest];
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
