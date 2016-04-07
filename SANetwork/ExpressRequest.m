//
//  ExpressRequest.m
//  SANetwork
//
//  Created by ISCS01 on 16/3/31.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "ExpressRequest.h"

@implementation ExpressRequest

- (instancetype)initWithType:(NSString *)expressType postId:(NSString *)postId
{
    self = [super init];
    if (self) {
        self.requestArgument = @{
                                 @"type" : expressType,
                                 @"postid" : postId
                                 };
    }
    return self;
}

- (SARequestMethod)requestMethod {
    return SARequestMethodPost;
}

- (NSString *)apiMethodName {
    return @"query";
}

@end
