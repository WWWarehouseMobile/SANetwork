//
//  SANetworkServiceProtocol.h
//  SANetworkDemo
//
//  Created by 学宝 on 2017/4/28.
//  Copyright © 2017年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkRequestConfigProtocol.h"


/**
 服务的验证结果状态

 - SAServiceAuthenticationStatusPass: 通过
 - SAServiceAuthenticationStatusWarning: 警告
 - SAServiceAuthenticationStatusWrong: 错误
 */
typedef NS_ENUM(NSInteger , SAServiceAuthenticationStatus) {
    SAServiceAuthenticationStatusPass = 0,
    SAServiceAuthenticationStatusWarning,
    SAServiceAuthenticationStatusWrong
};


@class SANetworkRequest;


/**
 网络接口服务配置协议
 */
@protocol SANetworkServiceProtocol <NSObject>

@required

/**
 服务接口地址的基础URL

 @return 接口基础地址
 */
- (NSString *)serviceApiBaseUrlString;


/**
 服务接口 Acceptable-Content 配置

 @return Acceptable-Content Types;
 */
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
 针对特定服务的请求响应数据的统一验证。将影响响应数据的状态

 @param networkRequest 网络接口请求对象
 @param response 网络接口响应数据
 @return 验证结果状态
 */
- (SAServiceAuthenticationStatus)serviceBaseAuthenticationWithNetworkRequest:(SANetworkRequest *)networkRequest response:(id)response;

/**
 *  @brief 请求失败之后的重试次数，最大设置为3次，默认为0
 *  @warning 仅限SANetworkResponseFailureStatus 或 SANetworkNotReachableStatus 失败状态下，起作用
 *  @return 重试次数
 */
- (NSUInteger)serviceRequestRetryCountWhenFailure;

/**
 *  @brief 请求超时时间，默认15秒
 *  @return 服务的请求超时时间
 */
- (NSTimeInterval)serviceRequestTimeoutInterval;

/*******以下协议的设定用于服务端返回数据的第一层格式统一，设定后，便于更深一层的取到数据 *********/


/**
 响应数据提示信息的key

 @return message key
 */
- (NSString *)responseMessageKey;


/**
 响应数据定制code的key

 @return code key
 */
- (NSString *)responseCodeKey;


/**
 响应数据具体内容的key

 @return content key
 */
- (NSString *)responseContentDataKey;



@end
