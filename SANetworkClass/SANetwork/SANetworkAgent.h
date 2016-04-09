//
//  SANetworkAgent.h
//  ECM
//
//  Created by 学宝 on 16/1/13.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

@class SANetworkRequest;

/**
 *  返回数据的基本验证，比如签名
 *
 *  @param response 请求返回的数据
 *
 *  @return 验证是否通过
 */
typedef BOOL (^SANetworkResponseBaseAuthenticationBlock)(SANetworkRequest *networkRequest, id response);

/**
 *  基本的请求参数，在较多接口都会使用到的参数，这些参数可以作为base参数设定，比如用户名、app标示、版本 等等
 *
 *  @return “基本”参数字典
 */
typedef NSDictionary<NSString *,NSString *>* (^SANetworkRequestBaseArgumentBlock)();

@interface SANetworkAgent : NSObject

+ (SANetworkAgent *)sharedInstance;

@property (nonatomic, strong, readwrite) NSString *mainBaseUrlString;// 主url

@property (nonatomic, strong, readwrite) NSString *viceBaseUrlString;// 副url

@property (nonatomic, copy) SANetworkResponseBaseAuthenticationBlock baseAuthenticationBlock;

@property (nonatomic, copy) SANetworkRequestBaseArgumentBlock baseArgumentBlock;

/**
 *  @brief 添加request到请求栈中，并启动
 *
 *  @param request 一个基于SABaseRequest的实例
 */
- (void)addRequest:(__kindof SANetworkRequest *)request;

/**
 *  @brief 结束一个请求，并从请求栈中移除
 *
 *  @param request 一个基于SABaseRequest的实例
 */
- (void)removeRequest:(__kindof SANetworkRequest *)request;


- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

@end
