//
//  SANetworkConfig.h
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/21.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkRequest.h"

/**
 *  @brief 返回需要统一设定的请求头
 *
 *  @return 请求头的字典
 */
typedef NSDictionary<NSString *,NSString *>* (^SANetworkRequestBaseHTTPRequestHeadersBlock)();

/**
 *  基本的请求参数，在较多接口都会使用到的参数，这些参数可以作为base参数设定，比如用户名、app标示、版本 等等
 *
 *  @return “基本”参数字典
 */
typedef NSDictionary<NSString *,NSString *>* (^SANetworkRequestBaseParamSourceBlock)();

/**
 *  @brief 返回需要统一设定的请求头
 *
 *  @return 请求头的字典
 */
typedef BOOL (^SANetworkResponseBaseAuthenticationBlock)(SANetworkRequest *networkRequest, id response);

/**
 *  @brief 网络配置类
 */

@interface SANetworkConfig : NSObject

+ (SANetworkConfig *)sharedInstance;

@property (nonatomic, copy) NSString *mainBaseUrlString;// 主url
@property (nonatomic, copy) NSString *viceBaseUrlString;// 副url

@property (nonatomic, copy) SANetworkRequestBaseHTTPRequestHeadersBlock baseHTTPRequestHeadersBlock;
@property (nonatomic, copy) SANetworkRequestBaseParamSourceBlock baseParamSourceBlock;
@property (nonatomic, copy) SANetworkResponseBaseAuthenticationBlock baseAuthenticationBlock;

/**
 *  @brief 设置请求的服务列表(针对后台配置定制，简单的话，就不需要)
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *urlSeriveDictionary;

/**
 *  @brief 默认SARequestSerializerTypeHTTP（即：[AFHTTPRequestSerializer serializer]）
 */
@property (nonatomic, assign) SARequestSerializerType requestSerializerType;

/**
 *  @brief 默认SAResponseSerializerTypeJSON (即：[AFJSONResponseSerializer serializer])
 */
@property (nonatomic, assign) SAResponseSerializerType responseSerializerType;

/**
 *  @brief 默认：[NSSet setWithObjects:@"application/json", @"text/json", @"text/html",nil]
 */
@property (nonatomic, copy) NSSet<NSString *> *acceptableContentTypes;

/**
 *  @brief 请求超时时间，默认20秒
 */
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

/**
 *  @brief 是否打开debug日志，默认关闭
 */
@property (nonatomic, assign) BOOL enableDebug;


/*******以下属性的设定用于服务端返回数据的第一层格式统一，设定后，便于更深一层的取到数据 *********/

@property (nonatomic, strong) NSString *responseMessageKey;
@property (nonatomic, strong) NSString *responseCodeKey;
@property (nonatomic, strong) NSString *responseContentDataKey;

@end
