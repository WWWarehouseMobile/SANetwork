//
//  SANetworkConstant.h
//  SANetworkDemo
//
//  Created by 学宝 on 2017/6/9.
//  Copyright © 2017年 WWWarehouse. All rights reserved.
//

#ifndef SANetworkConstant_h
#define SANetworkConstant_h

/**
 *  @brief 网络请求状态值
 */
typedef NS_ENUM(NSInteger, SANetworkStatus) {
    /**
     *  @brief 请求被取消，暂不提供响应回调
     */
    SANetworkRequestCancelStatus,
    /**
     *  @brief 网络不可达
     */
    SANetworkNotReachableStatus,
    /**
     *  @brief 请求参数错误
     */
    SANetworkRequestParamIncorrectStatus,
    /**
     *  @brief 请求失败
     */
    SANetworkResponseFailureStatus,
    /**
     *  @brief 请求返回的数据错误，可能是接口错误等
     */
    SANetworkResponseDataIncorrectStatus,
    /**
     *  @brief 请求返回的数据没有通过验证
     */
    SANetworkResponseDataAuthenticationFailStatus,
    /**
     *  @brief 数据请求成功
     */
    SANetworkResponseDataSuccessStatus,
};

#endif /* SANetworkConstant_h */
