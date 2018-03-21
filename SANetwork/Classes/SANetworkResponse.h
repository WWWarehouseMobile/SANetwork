//
//  SANetworkResponse.h
//  ECM
//
//  Created by 学宝 on 16/1/16.
//  Copyright © 2016年 WWWarehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SANetworkConstant.h"

@protocol SANetworkResponseReformerProtocol;


/**
 网络接口响应对象
 */
@interface SANetworkResponse : NSObject

/**
 *  请求得到的全部数据
 */
@property (nonatomic, copy, readonly) id responseData;

/**
 网络接口状态
 */
@property (nonatomic, assign, readonly) SANetworkStatus networkStatus;

/**
 网络接口请求的tag
 */
@property (nonatomic, assign, readonly) NSInteger requestTag;


/**
 初始化网络接口响应对象

 @param responseData 响应的原始数据
 @param serviceIdentifierKey 服务配置对象的存储标示
 @param requestTag 网络接口请求的tag
 @param networkStatus 网络接口的状态
 @return 网络接口响应对象
 */
- (instancetype)initWithResponseData:(id)responseData
                          serviceIdentifierKey:(NSString *)serviceIdentifierKey
                          requestTag:(NSInteger)requestTag
                       networkStatus:(SANetworkStatus)networkStatus;


/**
 更改数据格式

 @param reformer 提供怎么去更改的对象
 @return 更改后的数据
 */
- (id)fetchDataWithReformer:(id<SANetworkResponseReformerProtocol>)reformer;


/***  以下属性取决于你服务端返回的数据格式，以及对应Service对象是否设定了对应属性值的key值***/

/**
 请求无网、失败、参数错误、验证失败的情况，此属性都有值
 */
@property (nonatomic, copy, readonly) NSString *responseMessage;


/**
 响应数据的具体内容
 */
@property (nonatomic, copy, readonly) id responseContentData;


/**
 响应数据的定制code值
 */
@property (nonatomic, assign, readonly) NSInteger responseCode;
@end


/**
 响应对象数据改革协议
 */
@protocol SANetworkResponseReformerProtocol <NSObject>

@required

/**
 @param networkResponse 响应数据对象（SANetworkResponse）
 @param originData     响应的源数据
 @return 改革后的数据
 
 *  将数据进行一定的改造，方便在业务层统一处理
 *  引“RTNetworking”的注解：
 比如同样的一个获取电话号码的逻辑，二手房，新房，租房调用的API不同，所以它们的manager和data都会不同。
 即便如此，同一类业务逻辑（都是获取电话号码）还是应该写到一个reformer里面去的。这样后人定位业务逻辑相关代码的时候就非常方便了。
 代码样例：
 
         - (id)networkResponse:(SANetworkResponse *)networkResponse reformerDataWithOriginData:(id)originData
         {
             if (networkResponse.requestTag == xinfangManager.tag]) {
                 return [self xinfangPhoneNumberWithData:data];      //这是调用了派生后reformer子类自己实现的函数，别忘了reformer自己也是一个对象呀。
                 //reformer也可以有自己的属性，当进行业务逻辑需要一些外部的辅助数据的时候，
                 //外部使用者可以在使用reformer之前给reformer设置好属性，使得进行业务逻辑时，
                 //reformer能够用得上必需的辅助数据。
             }
             
             if (networkResponse.requestTag == zufangManager.tag) {
                 return [self zufangPhoneNumberWithData:data];
             }
             
             if (networkResponse.requestTag == ershoufangManager.tag) {
                 return [self ershoufangPhoneNumberWithData:data];
             }
         }
 

 */

- (id)networkResponse:(SANetworkResponse *)networkResponse reformerDataWithOriginData:(id)originData;



@end
