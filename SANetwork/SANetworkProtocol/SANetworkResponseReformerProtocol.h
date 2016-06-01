//
//  SANetworkResponseReformerProtocol.h
//  ECM
//
//  Created by 学宝 on 16/1/15.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  SANetworkResponse;

/**
 *  @brief 改革数据协议
 */
@protocol SANetworkResponseReformerProtocol <NSObject>

@required

/**
 *  @brief 将数据进行一定的改造，方便在业务层统一处理
 
 *  @see 引“RTNetworking”的注解：
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

 *
 *  @param networkResponse 响应数据对象（SANetworkResponse）
 *  @param originData     响应的源数据
 *
 *  @return 改革后的数据
 */
- (id)networkResponse:(SANetworkResponse *)networkResponse reformerDataWithOriginData:(id)originData;

@end
