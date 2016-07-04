//
//  AppDelegate.m
//  SANetwork
//
//  Created by ISCS01 on 16/3/25.
//  Copyright © 2016年 浙江网仓科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "SANetwork.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /**
     *  设定自己需要请求的URL
     */
    [SANetworkAgent sharedInstance].mainBaseUrlString = @"http://10.10.0.120:8080";
    /**
     *  当使用viceBaseUrlString时，请设定请求的SANetworkConfigProtocol中的viceBaseUrlString为YES
     */
//    [SANetworkAgent sharedInstance].viceBaseUrlString = @"http://www.kuaidi100.com";
    
//    [[SANetworkAgent sharedInstance] setBaseArgumentBlock:^NSDictionary *(){
//        /**
//         *  根据自己的接口中大部分接口所必须的参数，进行统一设定
//         */
//        return @{@"username" : @"001",
//                 @"password" : @"123"};
//    }];
    [[SANetworkAgent sharedInstance] setBaseAuthenticationBlock:^BOOL(SANetworkRequest *networkRequest, id response){
        /**
         *  可根据networkRequest、response进行验证
         */
        return YES;
    }];
    [[SANetworkAgent sharedInstance] setBaseHTTPRequestHeadersBlock:^ NSDictionary *(){
        return @{
                 @"m" : @"iOS",
                 @"v" : @"1.0.0",
                 @"t" : @"2016-06-04 14:18:05",
                 @"token" : @"8046DB4D7844617E0F9EC72A46CE4317",
                 @"sign" : @"F91D85521848A876340A1BF603994624"
                 };
    }];
    [SANetworkAgent sharedInstance].enableDebug = YES;
    
    /**
     *  根据自己的接口返回，自定义设置
     */
    [SANetworkResponse setResponseMessageKey:@"msg"];
    [SANetworkResponse setResponseCodeKey:@"code"];
    [SANetworkResponse setResponseContentDataKey:@"data"];
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
