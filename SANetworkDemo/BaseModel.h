//
//  BaseModel.h
//  SANetwork
//
//  Created by ISCS01 on 16/4/21.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject
@property (nonatomic, copy) NSArray *contentList;
@property (nonatomic, assign) long long allNum;
@property (nonatomic, assign) long long pageNum;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger pageSize;

@property (nonatomic, copy) NSString  *detailModelName;
@end

