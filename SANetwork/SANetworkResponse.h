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
typedef NS_ENUM(NSInteger, SANetworkResponseStatus) {
    /**
     *  请求失败
     */
    SANetworkResponseFailureStatus,
    /**
     *  允许缓存的接口，取到缓存数据
     */
    SANetworkResponseCacheStatus,
    /**
     *  请求返回的数据错误，可能是接口错误等等
     */
    SANetworkResponseIncorrectStatus,
    
    /**
     *  请求返回的数据没有通过验证
     */
    SANetworkResponseAuthenticationFailStatus,
    /**
     *  数据请求成功
     */
    SANetworkResponseSuccessStatus,
};

@interface SANetworkResponse : NSObject
/**
 *  请求得到的全部数据
 */
@property (nonatomic, copy, readonly) id responseData;

@property (nonatomic, assign, readonly) NSInteger requestTag;

@property (nonatomic, assign, readonly) BOOL isCache;

@property (nonatomic, assign, readonly) SANetworkResponseStatus networkResponseStatus;

- (instancetype)initWithResponseData:(id)responseData
                  responseModelClass:(Class)responseModelClass
                      requestTag:(NSInteger)requestTag
                   networkResponseStatus:(SANetworkResponseStatus)networkResponseStatus;

- (id)fetchDataWithReformer:(id<SANetworkResponseReformerProtocol>)reformer;


/**
 *  以下方法用于服务端返回数据的第一层格式统一，我针对于比较普通的数据格式，进行了对数据深入一层的解析
 *
 */
+ (void)setResponseCodeKey:(NSString *)codeKey;

+ (void)setResponseMessageKey:(NSString *)messageKey;

+ (void)setResponseContentDataKey:(NSString *)contentDataKey;

@property (nonatomic, copy, readonly) NSObject *contentData;

@property (nonatomic, copy, readonly) NSString *message;

@property (nonatomic, assign, readonly) NSInteger code;

@end
