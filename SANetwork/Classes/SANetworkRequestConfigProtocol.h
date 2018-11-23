//
//  SANetworkRequestConfigProtocol.h
//  SANetworkDemo
//
//  Created by 学宝 on 16/7/21.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFURLRequestSerialization.h>


/**
 网络接口请求方式
 */
typedef NS_ENUM(NSInteger , SARequestMethod) {
    /**Post请求*/
    SARequestMethodPost = 0,
    /**Get请求*/
    SARequestMethodGet,
};


/**
 请求序列化类型
 */
typedef NS_ENUM(NSInteger , SARequestSerializerType) {
    /**Http*/
    SARequestSerializerTypeHTTP = 0,
    /**Json*/
    SARequestSerializerTypeJSON,
    /**plist*/
    SARequestSerializerTypePropertyList,
};


/**
 响应数据序列化类型
 */
typedef NS_ENUM(NSInteger , SAResponseSerializerType) {
    /**Json*/
    SAResponseSerializerTypeJSON = 0,
    /**Http*/
    SAResponseSerializerTypeHTTP,
    /**xml*/
    SAResponseSerializerTypeXMLParser,
    /**plist*/
    SAResponseSerializerTypePropertyList,
    /**image*/
    SAResponseSerializerTypeImage,
};

/**
 *  @author 学宝
 *
 *  @brief 处理正在执行的前一个相同方法的请求的方式
 *  @warning 相同方法的请求是指url相同，参数可能不同
 */

/**
    处理正在执行与前一个相同方法请求的方式
 * 相同方法的请求是指url相同，参数可能不同
 */
typedef NS_ENUM(NSInteger , SARequestHandleSameRequestType) {
    /**取消正要启动的请求*/
    SARequestHandleSameRequestCancelCurrentType = 0,
    /**取消正在进行的请求*/
    SARequestHandleSameRequestCancelPreviousType,
    /**不取消请求，请求同时执行*/
    SARequestHandleSameRequestBothContinueType,
};


/**
 上传数据构造Block

 @param formData 要注入的上传信息
 */
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);


/**
 请求对象的配置协议
 */
@protocol SANetworkRequestConfigProtocol <NSObject>

@required

/**
 *  @brief 属于哪个服务。
 *  @warning 需要注意的是若想取到这个key对应的服务，要先使用这个key配置SANetworkConfig的setServiceObject:serviceIdentifier:。
 *  @return 服务的key （string）
 */
- (NSString *)serviceIdentifierKey;

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
 *  @brief 请求方式，默认为 SARequestMethodPost
 */
- (SARequestMethod)requestMethod;

/**
 *  @brief 请求所需要的参数
 *
 *  @return 参数字典
 */

- (NSDictionary *)requestParamDictionary;

/**
 *  @author 学宝
 *
 *  @brief 定制缓存策略，默认NSURLRequestUseProtocolCachePolicy
 *
 */
- (NSURLRequestCachePolicy)cachePolicy;

/**
 *  @brief 请求失败之后的重试次数，默认为0
 *  @warning 仅限SANetworkResponseFailureStatus 或 SANetworkNotReachableStatus 失败状态下，起作用
 *  @return 重试次数
 */
- (NSUInteger)requestRetryCountWhenFailure;

/**
 *  @brief 请求连接的超时时间。默认15秒
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


- (NSSet <NSString *> *)responseAcceptableContentTypes;

/**
 *  @brief 当POST的内容带有文件等富文本时使用
 *
 *  @return ConstructingBlock
 */
- (AFConstructingBlock)constructingBodyBlock;

/**
 *  @brief 处理正在执行相同方法的请求（参数可能不同），默认取消正要启动的请求SARequestHandleSameRequestCancelCurrentType
 *
 *  @return 处理方式
 */
- (SARequestHandleSameRequestType)handleSameRequestType;

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
 *  @warning 只作用于此接口
 *  @return 请求头数据
 */
- (NSDictionary *)customHTTPRequestHeaders;

/**
 *  @brief 是否启用SANetworkConfig设定的请求验证，若设定了验证的Block，默认使用YES
 *
 *  @return 是否使用基础的请求验证
 */
- (BOOL)useBaseAuthentication;

/**
 *  @author 学宝
 *
 *  @brief 定制是否输出log日志
 *  @warning 定制，将忽略SANetworkConfig的enableDebug
 *
 */
- (BOOL)enableDebugLog;
@end
