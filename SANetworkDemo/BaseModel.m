//
//  BaseModel.m
//  SANetwork
//
//  Created by ISCS01 on 16/4/21.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "BaseModel.h"
#import <YYModel/YYModel.h>

@implementation BaseModel

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"detailModelName"];
}

- (NSArray *)contentList {
    if (_contentList.count > 0 && [_contentList.lastObject isKindOfClass:[NSDictionary class]] && self.detailModelName != nil) {
        _contentList = [NSArray yy_modelArrayWithClass:NSClassFromString(self.detailModelName) json:_contentList];
    }
    return _contentList;
}
@end
