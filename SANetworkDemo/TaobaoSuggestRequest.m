//
//  TaobaoSuggestRequest.m
//  SANetworkDemo
//
//  Created by 詹学宝 on 2017/6/12.
//  Copyright © 2017年 学宝工作室. All rights reserved.
//

#import "TaobaoSuggestRequest.h"

@implementation TaobaoSuggestRequest

- (NSString *)requestMethodName {
    return @"sug";
}

- (NSString *)serviceIdentifierKey {
    return @"TaoBaoIdentifierKey";
}

- (BOOL)isCorrectWithResponseData:(id)responseData {
    if (responseData) {
        return YES;
    }
    return NO;
}

- (SARequestMethod)requestMethod {
    return SARequestMethodGet;
}

- (NSSet<NSString *> *)responseAcceptableContentTypes {
    return [NSSet setWithObject:@"text/html"];
}

- (NSDictionary *)requestParamDictionary {
    return @{
             @"code" : @"utf-8",
             @"q" : self.query,
             };
}
@end
