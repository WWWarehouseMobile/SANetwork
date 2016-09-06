//
//  SANetworkRequestConfigProtocol.h
//  SANetworkDemo
//
//  Created by 阿宝 on 16/7/21.
//  Copyright © 2016年 学宝工作室. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFURLRequestSerialization.h>

typedef NS_ENUM(NSInteger , SARequestMethod) {
    SARequestMethodPost = 0,
    SARequestMethodGet,
};

typedef NS_ENUM(NSInteger , SARequestSerializerType) {
    SARequestSerializerTypeHTTP = 0,
    SARequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger , SAResponseSerializerType) {
    SAResponseSerializerTypeJSON = 0,
    SAResponseSerializerTypeHTTP,
};

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@protocol SANetworkRequestConfigProtocol <NSObject>

@required

/**
 *  @brief 接口地址。若设置带有http的请求地址，将会忽略SANetworkConfig设置的url
 */
- (NSString *)requestMethodName;

/**
 *  @brief 检查返回数据是否正确，这样将在response里的succeed和failed 直接使用数据。
 *
 *  @param responseData 返回的完整数据
 *
 *  @return 是否正确
 */
- (BOOL)isCorrectWithResponseData:(id)responseData;

@optional

/**
 *  属于哪个服务，看具体服务端怎么写，简单的话，不用使用。
 *  @warning 需要注意的是若想取到这个key对应的服务，要配置SANetworkConfig的urlSeriveDictionary。若取到值以http开头，将忽略SANetworkConfig的mainBaseUrlString及viceBaseUrlString。
 *  @return 服务的key （string）
 */
- (NSString *)serviceKey;

/**
 *  @brief 请求方式，默认为 SARequestMethodPost
 */
- (SARequestMethod)requestMethod;


/**
 *  @brief 是否缓存数据 response。  默认NO
 *
 *  @return 是否缓存
 */
- (BOOL)shouldCacheResponse;

/**
 *  @brief 请求连接的超时时间。默认20.0秒
 *  @return 超时时长
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  @brief 检查请求参数
 *
 *  @param params 请求参数
 *
 *  @return 是否执行请求
 */
- (BOOL)isCorrectWithRequestParams:(NSDictionary *)params;

/**
 *  @brief 请求的SerializerType 默认SARequestSerializerTypeJSON, 可通过SANetworkConfig设置默认值
 *  @return 服务端接受数据类型
 */
- (SARequestSerializerType)requestSerializerType;

/**
 *  @brief 响应数据的responseSerializerType，默认SAResponseSerializerTypeJSON，可通过SANetworkConfig设置默认值
 *
 *  @return 服务端返回的数据类型
 */
- (SAResponseSerializerType)responseSerializerType;

/**
 *  @brief 当POST的内容带有文件等富文本时使用
 *
 *  @return ConstructingBlock
 */
- (AFConstructingBlock)constructingBodyBlock;

/**
 *  @brief 是否取消正在执行的前一个相同方法的请求（参数可能不同）
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

/**
 *  很多请求都会需要相同的请求参数，可设置SANetworkConfig的baseParamSourceBlock，这个block会返回你所设置的基础参数。默认YES
 *
 *  @return 是否使用基础参数
 */
- (BOOL)useBaseRequestParamSource;

/**
 *  @brief SANetworkConfig设置过baseHTTPRequestHeadersBlock后，可通过此协议方法决定是否使用baseHTTPRequestHeaders，默认使用（YES）
 *
 *  @return 是否使用baseHTTPRequestHeaders
 */
- (BOOL)useBaseHTTPRequestHeaders;

/**
 *  @brief 定制请求头
 *
 *  @return 请求头数据
 */
- (NSDictionary *)customHTTPRequestHeaders;

/**
 *  @brief 是否启用SANetworkConfig设定的请求验证，若设定了验证的Block，默认使用YES
 *
 *  @return 是否使用基础的请求验证
 */
- (BOOL)useBaseAuthentication;
@end
