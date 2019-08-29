//
//  SANetworkBatchRequest.m
//  ECM
//
//  Created by 学宝 on 16/1/18.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import "SANetworkBatchRequest.h"
#import "SANetworkResponseProtocol.h"
#import "SANetworkRequest.h"
#import "SANetworkAgent.h"
#import "SANetworkResponse.h"

@interface SANetworkBatchRequest ()<SANetworkResponseProtocol>

@property (nonatomic) NSInteger completedCount;
@property (nonatomic, strong) NSArray<SANetworkRequest *> *requestArray;
@property (nonatomic, strong) NSMutableArray<SANetworkResponse *> *responseArray;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableArray *accessoryArray;

@end

@implementation SANetworkBatchRequest

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
    [[SANetworkAgent sharedInstance] addBatchRequest:self];
    [self accessoryWillStart];
    self.queue.maxConcurrentOperationCount = self.maxConcurrentCount;
    _completedCount = 0;
    
    NSArray *tempArr = [self.requestArray sortedArrayUsingComparator:^NSComparisonResult(SANetworkRequest * _Nonnull obj1, SANetworkRequest * _Nonnull obj2) {
        if ((int)obj1.priorityType > (int)obj2.priorityType) {
            return NSOrderedAscending;
        }else if ((int)obj1.priorityType == (int)obj2.priorityType) {
            return NSOrderedSame;
        }
        return NSOrderedDescending;
    }];
    
    self.requestArray = tempArr.copy;
    
    for (SANetworkRequest * _Nonnull request in self.requestArray) {
        request.responseDelegate = self;
        
        NSOperation * op = [NSBlockOperation blockOperationWithBlock:^{
            [[SANetworkAgent sharedInstance] addRequest:request];
        }];
        op.qualityOfService = NSQualityOfServiceUserInteractive;
        switch (request.priorityType) {
            case SANetworkPriorityTypeVeryHigh:
                op.queuePriority = NSOperationQueuePriorityVeryHigh;
                break;
            case SANetworkPriorityTypeDefaultHigh:
                op.queuePriority = NSOperationQueuePriorityHigh;
                break;
            case SANetworkPriorityTypeDefaultLow:
                op.queuePriority = NSOperationQueuePriorityLow;
                break;
            case SANetworkPriorityTypeVeryLow:
                op.queuePriority = NSOperationQueuePriorityVeryLow;
                break;
            default:
                op.queuePriority = NSOperationQueuePriorityNormal;
                break;
        }
        [_queue addOperation:op];
    }
    [self accessoryDidStart];
}

- (void)stopBatchRequest {
    _delegate = nil;
    [_queue cancelAllOperations];
    for (SANetworkRequest *networkRequest in self.requestArray) {
        [[SANetworkAgent sharedInstance] removeRequest:networkRequest];
    }
}

#pragma mark -
#pragma mark - SANetworkAccessoryProtocol

- (void)addNetworkAccessoryObject:(id<SANetworkAccessoryProtocol>)accessoryDelegate {
    if (!accessoryDelegate) return;
    if (!_accessoryArray) {
        _accessoryArray = [[NSMutableArray alloc]init];
    }
    [_accessoryArray addObject:accessoryDelegate];
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

- (void)accessoryFinish {
    for (id<SANetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidFinish)]) {
            [accessory networkRequestAccessoryDidFinish];
        }
    }
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
    
    if (self.completedCount == self.requestArray.count) {
        [self networkBatchRequestCompleted];
    }
}

- (void)networkBatchRequestCompleted{
    if ([self.delegate respondsToSelector:@selector(networkBatchRequest:completedByResponseArray:)]) {
        [self.delegate networkBatchRequest:self completedByResponseArray:self.responseArray];
    }
    self.completedCount = -1;
    [self accessoryFinish];
    [[SANetworkAgent sharedInstance] removeBatchRequest:self];
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
    }
    return _queue;
}

- (void)dealloc {
    for (SANetworkRequest *networkRequest in self.requestArray) {
        [[SANetworkAgent sharedInstance] removeRequest:networkRequest];
    }
}

@end
