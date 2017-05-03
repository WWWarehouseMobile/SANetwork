//
//  SANetworkServiceProtocol.h
//  SANetworkDemo
//
//  Created by 詹学宝 on 2017/4/28.
//  Copyright © 2017年 学宝工作室. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkRequestConfigProtocol.h"

@class SANetworkRequest;
@protocol SANetworkServiceProtocol <NSObject>

@required
- (NSString *)serviceApiBaseUrlString;

- (NSSet<NSString *> *)serviceResponseAcceptableContentTypes;

@optional
/**
 *  @brief 默认SARequestSerializerTypeHTTP（即：[AFHTTPRequestSerializer serializer]）
 */
- (SARequestSerializerType)serviceRequestSerializerType;

/**
 *  @brief 默认SAResponseSerializerTypeJSON (即：[AFJSONResponseSerializer serializer])
 */
- (SAResponseSerializerType)serviceResponseSerializerType;

/**
 *  @brief 返回需要统一设定的请求头
 *
 *  @return 请求头的字典
 */
- (NSDictionary<NSString *,NSString *> *)serviceBaseHTTPRequestHeaders;

/**
 *  基本的请求参数，在较多接口都会使用到的参数，这些参数可以作为base参数设定，比如用户名、app标示、版本 等等
 *
 *  @return “基本”参数字典
 */
- (NSDictionary<NSString *,NSString *> *)serviceBaseParamSource;

/**
 *  @author 学宝
 *
 *  @brief 针对特定服务的请求响应数据的统一验证。将影响响应数据的状态
 *
 */
- (BOOL)serviceBaseAuthenticationWithNetworkRequest:(SANetworkRequest *)networkRequest resonse:(id)response;

/**
 *  @brief 请求超时时间，默认20秒
 */
- (NSTimeInterval)serviceRequestTimeoutInterval;



/*******以下协议的设定用于服务端返回数据的第一层格式统一，设定后，便于更深一层的取到数据 *********/

- (NSString *)responseMessageKey;

- (NSString *)responseCodeKey;

- (NSString *)responseContentDataKey;
@end
