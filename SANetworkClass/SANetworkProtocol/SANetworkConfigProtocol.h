//
//  SARequestConfigProtocol.h
//  ECM
//
//  Created by 学宝 on 16/1/15.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFURLRequestSerialization.h>

typedef NS_ENUM(NSInteger , SARequestMethod) {
    SARequestMethodGet = 0,
    SARequestMethodPost,
};

typedef NS_ENUM(NSInteger , SARequestSerializerType) {
    SARequestSerializerTypeHTTP = 0,
    SARequestSerializerTypeJSON,
};

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@protocol SANetworkConfigProtocol <NSObject>

@required

/**
 *  @brief 接口地址
 */
- (NSString *)requestMethodName;

/**
 *  @brief 检查返回数据是否正确，这样将在response里的succeed和failed 直接使用数据。
 *
 *  @param responseData 将返回的数据
 *
 *  @return 是否正确
 */
- (BOOL)isCorrectWithResponseData:(id)responseData;

@optional

/**
 *  @brief 请求方式
 */
- (SARequestMethod)requestMethod;

/**
 *  很多请求都会需要相同的请求参数，可设置SANetworkAgent的baseArgumentBlock，这个block会返回你所设置的基础参数。默认YES
 *
 *  @return 是否使用基础参数
 */
- (BOOL)useBaseRequestArgument;

/**
 *  @brief 是否缓存数据 response。  默认NO
 *
 *  @return 是否缓存
 */
- (BOOL)shouldCacheResponse;

/**
 *  数据Model化，指定请求结果数据的对象类
 *
 *  @return 类
 */
- (Class)responseDataModelClass;

/**
 *  @brief 检查请求参数
 *
 *  @param params 请求参数
 *
 *  @return 是否执行请求
 */
- (BOOL)isCorrectWithRequestParams:(NSDictionary *)params;

/**
 *  @brief 请求连接的超时时间。默认30.0秒
 *  @return 超时时长
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  @brief 构建自定义的请求URL字符串
 *
 *  @return url字符串
 */
- (NSString *)customRequestURLString;

/**
 *  @brief 请求的SerializerType 默认SARequestSerializerTypeHTTP
 *  @return 服务端接受数据类型
 */
- (SARequestSerializerType)requestSerializerType;

/**
 *  @brief 当POST的内容带有文件等富文本时使用
 *
 *  @return ConstructingBlock
 */
- (AFConstructingBlock)constructingBodyBlock;


/**
 *  @brief 是否取消存在的在执行的前一个相同方法的请求
 *
 *  @return 是否取消前一个请求
 */
- (BOOL)shouldCancelPreviousRequest;


/**
 *  @brief 可以使用两个根地址，比如可能会用到 CDN 地址、https之类的。默认NO
 *
 *  @return 是否使用副Url
 */
- (BOOL)useViceURL;

@end
