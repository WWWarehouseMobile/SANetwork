//
//  TaobaoSuggestRequest.m
//  SANetworkDemo
//
//  Created by 学宝 on 2017/6/12.
//  Copyright © 2017年 WWWarehouse. All rights reserved.
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

- (void)dealloc {
    NSLog(@"TaobaoSuggestRequest -- dealloc");
}
@end
