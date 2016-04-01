//
//  SANetworkResponse.h
//  ECM
//
//  Created by 学宝 on 16/1/16.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkResponseReformerProtocol.h"

/**
 *  网络请求状态值
 */
typedef NS_ENUM(NSInteger, SANetworkStatus) {
    /**
     *  请求超时
     */
    SANetworkStatusTimeout,
    /**
     *  允许缓存的接口，取到缓存数据
     */
    SANetworkStatusCache,
    /**
     *  请求返回的数据错误，可能是接口错误等等
     */
    SANetworkStatusResponseDataIncorrect,
    
    /**
     *  请求返回的数据没有通过验证
     */
    SANetworkStatusResponseDataFailAuthentication,
    /**
     *  数据请求成功
     */
    SANetworkStatusSuccess,
};

@interface SANetworkResponse : NSObject

@property (nonatomic, copy, readonly) NSURLSessionDataTask *sessionDataTask;

/**
 *  请求得到的全部数据
 */
@property (nonatomic, copy, readonly) id responseData;

@property (nonatomic, assign, readonly) NSInteger requestTag;

@property (nonatomic, assign, readonly) BOOL isCache;

@property (nonatomic, assign, readonly) SANetworkStatus networkStatus;

- (instancetype)initWithResponse:(id)response
                 sessionDataTask:(NSURLSessionDataTask *)sessionDataTask
                      requestTag:(NSInteger)requestTag
                   networkStatus:(SANetworkStatus)networkStatus;

- (id)fetchDataWithReformer:(id<SANetworkResponseReformerProtocol>)reformer;


/**
 *  以下方法用于服务端返回数据的第一层格式统一，我针对于比较普通的数据格式，进行了对数据深入一层的解析
 *
 */
+ (void)setResponseCodeKey:(NSString *)codeKey;

+ (void)setResponseMessageKey:(NSString *)messageKey;

+ (void)setResponseContentDataKey:(NSString *)contentDataKey;

@property (nonatomic, copy, readonly) id contentData;

@property (nonatomic, copy, readonly) NSString *message;

@property (nonatomic, assign, readonly) NSInteger code;

@end
