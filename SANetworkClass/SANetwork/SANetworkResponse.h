//
//  SANetworkResponse.h
//  ECM
//
//  Created by 学宝 on 16/1/16.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkResponseReformerProtocol.h"

typedef NS_ENUM(NSInteger, SANetworkStatus) {
    SANetworkStatusNoNet,
    SANetworkStatusTimeout,
    SANetworkStatusCache,
    SANetworkStatusResponseDataIncorrect,
    SANetworkStatusSuccess,
};

@interface SANetworkResponse : NSObject

@property (nonatomic, copy, readonly) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, copy, readonly) id contentData;

@property (nonatomic, copy, readonly) NSString *message;

@property (nonatomic, assign, readonly) NSInteger requestTag;

@property (nonatomic, assign, readonly) BOOL isCache;

@property (nonatomic, assign, readonly) SANetworkStatus networkStatus;

- (instancetype)initWithResponse:(id)response
                 sessionDataTask:(NSURLSessionDataTask *)sessionDataTask
                      requestTag:(NSInteger)requestTag
                   networkStatus:(SANetworkStatus)networkStatus;

- (id)fetchDataWithReformer:(id<SANetworkResponseReformerProtocol>)reformer;

@end
